import hashlib
import io
import lzma
import os
import re
import shutil
import struct
import subprocess
import tarfile
import threading
import zlib

FORMAT_VERSION = 1

AR_MAGIC = b"!<arch>\n"
AR_HEADER_SIZE = 60
HASH_CHUNK_SIZE = 1024 * 1024
GZIP_WBITS_FLAG = 16
UIMAGE_MAGIC = 0x27051956
UIMAGE_HEADER_SIZE = 64
UIMAGE_TYPE_OFFSET = 30
UIMAGE_TYPE_SCRIPT = 6

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

# tasks that do not change what the recipe puts into the image; config and
# clean tasks are named one by one, because build tasks such as
# do_write_config end in config too
_TASKS_NOT_HASHED = re.compile(
    r"^do_(build|checkuri|listtasks|printdiff|clean|cleanall|cleansstate|cleanccache|clean_discovery"
    r"|buildclean|.*devshell|menuconfig|diffconfig|savedefconfig|showconfig|ccmake_diffconfig"
    r"|.*spdx.*|.*cve_check.*|.*qa|populate_lic|rm_work.*|dependencytrack_.*|.*_setscene)$")


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
    return _JOBS.sub("-j <N>", value)


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(HASH_CHUNK_SIZE), b""):
            h.update(chunk)
    return h.hexdigest()


def sha256_dir(path):
    """
    Hash the relative names and the content of all files below `path`. A
    symlink is hashed by its target, as it is unpacked.
    """
    h = hashlib.sha256()
    for root, dirs, files in os.walk(path):
        dirs.sort()
        links = [name for name in dirs if os.path.islink(os.path.join(root, name))]
        for name in sorted(files + links):
            full = os.path.join(root, name)
            h.update(os.path.relpath(full, path).encode() + b"\0")
            if os.path.islink(full):
                h.update(b"link:" + os.readlink(full).encode() + b"\0")
            else:
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


def parse_manifest(text):
    """Return {package: (arch, version)} from an image manifest."""
    installed = {}
    for line in text.splitlines():
        fields = line.split()
        if len(fields) == 3:
            installed[fields[0]] = (fields[1], fields[2])
    return installed


def parse_pkgdata(text):
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
    files that need a shared library of another recipe. Path dependencies
    (interpreters, update-alternatives links) are left out: their provider
    depends on the alternative priorities and is often not in pkgdata.
    """
    provider_of = {}
    for pn, (provides, _) in files_by_pn.items():
        for items in provides.values():
            for item in items:
                if not item.startswith("/"):
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


def task_hashes(basehashes):
    """The basehashes of the tasks that can change the output of a recipe."""
    return {task: h for task, h in sorted(basehashes.items()) if not _TASKS_NOT_HASHED.match(task)}


def deploy_dependencies(task_depends):
    """
    Return the recipe names whose do_deploy one of `task_depends` (the
    [depends] flags of the image tasks) needs.
    """
    names = set()
    for depends in task_depends:
        for dep in (depends or "").split():
            name, _, task = dep.partition(":")
            if task == "do_deploy":
                names.add(name)
    return names


def resolve_names(names, recipes):
    """Map recipe names and PROVIDES entries in `names` to the PN in `recipes`."""
    pn_of = {}
    for pn, r in recipes.items():
        for name in [pn] + list(r.get("provides", [])):
            pn_of.setdefault(name, pn)
    return {pn_of[name] for name in names if name in pn_of}


def check_merge(facts, other, name):
    """Fail if the facts of another image belong to another build."""
    for key in ("format_version", "machine", "distro_version"):
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
        mine["deploys"] = mine["deploys"] or r["deploys"]
    return recipes


def unit_links(unit_dir):
    """
    Return {link: target} of all symlinks below `unit_dir`: enabled units
    (*.wants, *.requires), default.target and masked units (/dev/null).
    """
    links = {}
    for root, dirs, files in os.walk(unit_dir):
        for name in dirs + files:
            full = os.path.join(root, name)
            if os.path.islink(full):
                links[os.path.relpath(full, unit_dir)] = os.readlink(full)
    return dict(sorted(links.items()))


def uboot_script(data):
    """Return the text of a U-Boot script image (mkimage -T script)."""
    if len(data) < UIMAGE_HEADER_SIZE or struct.unpack_from(">I", data)[0] != UIMAGE_MAGIC \
            or data[UIMAGE_TYPE_OFFSET] != UIMAGE_TYPE_SCRIPT:
        raise ValueError("not a U-Boot script image")
    # the header is followed by the sizes of the parts, ending with 0
    offset = UIMAGE_HEADER_SIZE
    sizes = []
    try:
        while True:
            (size,) = struct.unpack_from(">I", data, offset)
            offset += 4
            if not size:
                break
            sizes.append(size)
    except struct.error:
        raise ValueError("U-Boot script image is truncated")
    if not sizes or len(data) < offset + sizes[0]:
        raise ValueError("U-Boot script image is truncated")
    return data[offset:offset + sizes[0]].decode()


def boot_args(path):
    """
    Return the kernel arguments that a boot file adds: the `setenv bootargs`
    lines of a U-Boot script, the `linux` lines of a GRUB config, else the
    whole text.
    """
    with open(path, "rb") as f:
        data = f.read()
    if data[:4] == struct.pack(">I", UIMAGE_MAGIC):
        return _lines_starting_with(uboot_script(data), ["setenv", "bootargs"], "U-Boot script")
    try:
        text = data.decode()
    except UnicodeDecodeError:
        raise ValueError("not a U-Boot script image and not UTF-8 text")
    if any(line.split()[:1] == ["menuentry"] for line in text.splitlines()):
        return _lines_starting_with(text, ["linux"], "GRUB config")
    return normalize_ws(text)


def _lines_starting_with(text, words, kind):
    lines = [normalize_ws(line) for line in text.splitlines() if line.split()[:len(words)] == words]
    if not lines:
        raise ValueError("%s has no line that starts with '%s'" % (kind, " ".join(words)))
    return "\n".join(lines)
