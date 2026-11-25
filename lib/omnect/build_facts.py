import hashlib
import lzma
import os
import re
import shutil
import subprocess
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
)


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


def _hash_zstd(chunks):
    if not shutil.which("zstd"):
        raise ValueError("zstd not found")
    h = hashlib.sha256()
    proc = subprocess.Popen(["zstd", "-dc"], stdin=subprocess.PIPE, stdout=subprocess.PIPE)

    def feed():
        try:
            for chunk in chunks:
                proc.stdin.write(chunk)
        finally:
            proc.stdin.close()

    feeder = threading.Thread(target=feed)
    feeder.start()
    for chunk in iter(lambda: proc.stdout.read(HASH_CHUNK_SIZE), b""):
        h.update(chunk)
    feeder.join()
    if proc.wait() != 0:
        raise ValueError("zstd failed")
    return h.hexdigest()


def _hash_with(decompressor, chunks):
    h = hashlib.sha256()
    for chunk in chunks:
        h.update(decompressor.decompress(chunk))
    return h.hexdigest()


def ipk_data_sha256(path):
    """
    sha256 of the uncompressed data.tar of an ipk. The compressed member is
    not hashed, so the hash does not depend on compressor settings.
    """
    members = ar_members(path)
    name = next((m for m in members if m.startswith("data.tar")), None)
    if name is None:
        raise ValueError(f"{path}: no data.tar member")
    offset, size = members[name]
    with open(path, "rb") as f:
        f.seek(offset)
        chunks = _member_chunks(f, size)
        if name.endswith(".zst"):
            return _hash_zstd(chunks)
        if name.endswith(".xz"):
            return _hash_with(lzma.LZMADecompressor(), chunks)
        if name.endswith(".gz"):
            return _hash_with(zlib.decompressobj(zlib.MAX_WBITS | GZIP_WBITS_FLAG), chunks)
        if name == "data.tar":
            return _hash_with(_Identity(), chunks)
    raise ValueError(f"{path}: unknown compression of {name}")


class _Identity:
    def decompress(self, chunk):
        return chunk


def ipk_filename(name, version, arch):
    """File name of an ipk; the epoch of the version is not part of it."""
    return f"{name}_{version.split(':', 1)[-1]}_{arch}.ipk"


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
