import hashlib
import io
import lzma
import os
import re
import shutil
import subprocess
import tarfile
import threading
import zlib

FORMAT_VERSION = 1

AR_MAGIC = b"!<arch>\n"
AR_HEADER_SIZE = 60
HASH_CHUNK_SIZE = 1024 * 1024
# zlib window flag that accepts the gzip header
GZIP_WBITS_FLAG = 16

CONFIGURE_ARGS_BY_CLASS = (
    ("autotools", "EXTRA_OECONF"),
    ("cmake", "EXTRA_OECMAKE"),
    ("meson", "EXTRA_OEMESON"),
    ("cargo", "CARGO_BUILD_FLAGS"),
    ("go", "GOBUILDFLAGS"),
)

# control.tar members that change what installing the package does; the
# control file is left out, it holds the version
CONTROL_SCRIPTS = ("conffiles", "postinst", "postrm", "preinst", "prerm")


def normalize_ws(value):
    return " ".join((value or "").split())


def sorted_words(value):
    return sorted(set((value or "").split()))


def replace_paths(value, paths):
    """
    Replace each path of `paths` (placeholder -> path) in `value` by its
    placeholder. Longer paths go first, so WORKDIR wins over TMPDIR.
    """
    for placeholder, path in sorted(paths.items(), key=lambda p: len(p[1]), reverse=True):
        if path:
            value = value.replace(path, placeholder)
    return value


_JOBS = re.compile(r"(?<![\w-])-j\s*\d+")


def mask_jobs(value):
    """Replace the host specific number of make jobs ("-j 16") by "-j <N>"."""
    return _JOBS.sub("-j <N>", value)


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(HASH_CHUNK_SIZE), b""):
            h.update(chunk)
    return h.hexdigest()


def sha256_dir(path):
    """Hash the relative names and the content of all files below `path`."""
    h = hashlib.sha256()
    for root, dirs, files in os.walk(path):
        dirs.sort()
        for name in sorted(files):
            full = os.path.join(root, name)
            h.update(os.path.relpath(full, path).encode() + b"\0")
            h.update(sha256_file(full).encode() + b"\0")
    return h.hexdigest()


def sha256_path(path):
    return sha256_dir(path) if os.path.isdir(path) else sha256_file(path)


def ar_members(path):
    """Return {name: (offset, size)} of the members of an ar archive (ipk)."""
    members = {}
    with open(path, "rb") as f:
        if f.read(len(AR_MAGIC)) != AR_MAGIC:
            raise ValueError(f"{path}: not an ar archive")
        while True:
            header = f.read(AR_HEADER_SIZE)
            if len(header) < AR_HEADER_SIZE:
                break
            name = header[0:16].decode().strip().rstrip("/")
            size = int(header[48:58].decode().strip())
            members[name] = (f.tell(), size)
            # members are aligned to two bytes
            f.seek(size + (size % 2), os.SEEK_CUR)
    return members


def _member_chunks(f, size):
    while size > 0:
        chunk = f.read(min(HASH_CHUNK_SIZE, size))
        if not chunk:
            raise ValueError("truncated ar member")
        size -= len(chunk)
        yield chunk


def _zstd_chunks(chunks):
    if not shutil.which("zstd"):
        raise ValueError("zstd not found")
    proc = subprocess.Popen(["zstd", "-dc"], stdin=subprocess.PIPE, stdout=subprocess.PIPE)

    def feed():
        try:
            for chunk in chunks:
                proc.stdin.write(chunk)
        finally:
            proc.stdin.close()

    feeder = threading.Thread(target=feed)
    feeder.start()
    yield from iter(lambda: proc.stdout.read(HASH_CHUNK_SIZE), b"")
    feeder.join()
    if proc.wait() != 0:
        raise ValueError("zstd failed")


def _decompressed(name, chunks):
    if name.endswith(".zst"):
        return _zstd_chunks(chunks)
    if name.endswith(".xz"):
        decompressor = lzma.LZMADecompressor()
    elif name.endswith(".gz"):
        decompressor = zlib.decompressobj(zlib.MAX_WBITS | GZIP_WBITS_FLAG)
    elif name.endswith(".tar"):
        return chunks
    else:
        raise ValueError(f"unknown compression of {name}")
    return (decompressor.decompress(chunk) for chunk in chunks)


def _member(members, prefix, path):
    name = next((m for m in members if m.startswith(prefix)), None)
    if name is None:
        raise ValueError(f"{path}: no {prefix} member")
    return name


def ipk_sha256(path):
    """
    sha256 of the uncompressed data.tar and of the maintainer scripts of an
    ipk. The compressed members are not hashed, so the hash does not depend
    on compressor settings.
    """
    members = ar_members(path)
    h = hashlib.sha256()
    with open(path, "rb") as f:
        name = _member(members, "data.tar", path)
        offset, size = members[name]
        f.seek(offset)
        for chunk in _decompressed(name, _member_chunks(f, size)):
            h.update(chunk)

        name = _member(members, "control.tar", path)
        offset, size = members[name]
        f.seek(offset)
        control = b"".join(_decompressed(name, _member_chunks(f, size)))
    with tarfile.open(fileobj=io.BytesIO(control)) as tar:
        scripts = {os.path.basename(m.name): m for m in tar.getmembers() if m.isfile()}
        for script in CONTROL_SCRIPTS:
            if script in scripts:
                h.update(script.encode() + b"\0")
                h.update(tar.extractfile(scripts[script]).read() + b"\0")
    return h.hexdigest()


def ipk_filename(name, version, arch):
    """File name of an ipk; opkg-build leaves out a one-character epoch."""
    return f"{name}_{re.sub(r'^.:', '', version)}_{arch}.ipk"


def parse_pkgdata(text):
    """Parse a pkgdata file ("KEY: value" lines) into a dict."""
    result = {}
    for line in text.splitlines():
        key, sep, value = line.partition(": ")
        if sep:
            result[key] = value
        elif line.endswith(":"):
            result[line[:-1]] = ""
    return result


_PER_FILE_KEY = re.compile(r"^(FILERDEPENDS|FILERPROVIDES):(.+):([^:]+)$")
_VERSION_CONSTRAINT = re.compile(r"\s*\([<>=]+[^)]*\)")


def per_file_deps(pkgdata):
    """
    Return ({file: [provides]}, {file: [depends]}) from the FILERPROVIDES and
    FILERDEPENDS entries of one runtime pkgdata dict.
    """
    provides, depends = {}, {}
    for key, value in pkgdata.items():
        m = _PER_FILE_KEY.match(key)
        if not m:
            continue
        target = provides if m.group(1) == "FILERPROVIDES" else depends
        target[m.group(2)] = _VERSION_CONSTRAINT.sub("", value).split()
    return provides, depends


def linked_by(files_by_pn):
    """
    `files_by_pn` maps a recipe to ({file: [provides]}, {file: [depends]}) of
    its installed packages. Return {provider pn: {file: consumer pn}} for the
    files that need a provide of another recipe.
    """
    provider_of = {}
    for pn, (provides, _) in files_by_pn.items():
        for items in provides.values():
            for item in items:
                provider_of.setdefault(item, pn)

    result = {}
    for pn, (_, depends) in files_by_pn.items():
        for path, items in depends.items():
            for item in items:
                provider = provider_of.get(item)
                if provider and provider != pn:
                    result.setdefault(provider, {})[path] = pn
    return {pn: dict(sorted(files.items())) for pn, files in result.items()}


def built_into(recipes):
    """
    `recipes` maps a recipe to {"provides": [...], "depends": [...]}. Return
    {pn: [recipes that have pn in DEPENDS]}, limited to the given recipes.
    """
    pn_of = {}
    for pn, r in recipes.items():
        for name in [pn] + list(r.get("provides", [])):
            pn_of.setdefault(name, pn)

    result = {pn: set() for pn in recipes}
    for consumer, r in recipes.items():
        for dep in r.get("depends", []):
            provider = pn_of.get(dep)
            if provider and provider != consumer:
                result[provider].add(consumer)
    return {pn: sorted(consumers) for pn, consumers in result.items()}


def check_merge(facts, other, name):
    """Fail if the facts of another image belong to another build."""
    for key in ("machine", "distro_version"):
        if facts[key] != other[key]:
            raise ValueError(f"{name}: {key} is {other[key]}, expected {facts[key]}")


def merge_recipes(recipes, other):
    """
    Add the recipes of another image of the same device (e.g. the initramfs)
    to `recipes`. The data store fields of a recipe are the same in both
    images; packages, users and consumers are joined.
    """
    for pn, r in other.items():
        if pn not in recipes:
            recipes[pn] = r
            continue
        mine = recipes[pn]
        mine["installed_packages"] = dict(sorted({**mine["installed_packages"], **r["installed_packages"]}.items()))
        mine["linked_by"] = dict(sorted({**mine["linked_by"], **r["linked_by"]}.items()))
        mine["built_into"] = sorted(set(mine["built_into"]) | set(r["built_into"]))
    return recipes


def enabled_units(unit_dir):
    """
    Return the "<target>.wants/<unit>" and "<target>.requires/<unit>" links in
    `unit_dir`, the units that were enabled in the rootfs.
    """
    if not os.path.isdir(unit_dir):
        return []
    units = set()
    for entry in os.listdir(unit_dir):
        if entry.endswith(".wants") or entry.endswith(".requires"):
            for unit in os.listdir(os.path.join(unit_dir, entry)):
                units.add(f"{entry}/{unit}")
    return sorted(units)
