import gzip
import hashlib
import io
import lzma
import os
import shutil
import subprocess
import tarfile
import tempfile
import unittest

from omnect import build_facts

DATA_TAR = b"tar content " * 1000


def ar_member(name, data):
    header = f"{name + '/':<16}{0:<12}{0:<6}{0:<6}{'100644':<8}{len(data):<10}`\n".encode()
    return header + data + (b"\n" if len(data) % 2 else b"")


def control_tar(files):
    buf = io.BytesIO()
    with tarfile.open(fileobj=buf, mode="w") as tar:
        for name, content in files.items():
            info = tarfile.TarInfo("./" + name)
            info.size = len(content)
            tar.addfile(info, io.BytesIO(content))
    return gzip.compress(buf.getvalue())


def write_ipk(path, data_name, data, control=None):
    with open(path, "wb") as f:
        f.write(build_facts.AR_MAGIC)
        f.write(ar_member("debian-binary", b"2.0\n"))
        f.write(ar_member("control.tar.gz", control_tar(control or {"control": b"Version: 1\n"})))
        f.write(ar_member(data_name, data))


class IpkTest(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, self.dir)
        self.expected = hashlib.sha256(DATA_TAR).hexdigest()

    def hash(self, data_name, data, control=None):
        path = os.path.join(self.dir, "p.ipk")
        write_ipk(path, data_name, data, control)
        return build_facts.ipk_sha256(path)

    def check(self, data_name, data):
        self.assertEqual(self.hash(data_name, data), self.expected)

    def test_xz(self):
        self.check("data.tar.xz", lzma.compress(DATA_TAR))

    def test_gz(self):
        self.check("data.tar.gz", gzip.compress(DATA_TAR))

    def test_uncompressed_odd_size(self):
        self.expected = hashlib.sha256(DATA_TAR + b"x").hexdigest()
        self.check("data.tar", DATA_TAR + b"x")

    @unittest.skipUnless(shutil.which("zstd"), "zstd not installed")
    def test_zst(self):
        data = subprocess.run(["zstd", "-c"], input=DATA_TAR, stdout=subprocess.PIPE, check=True).stdout
        self.check("data.tar.zst", data)

    def test_compression_level_does_not_change_hash(self):
        self.check("data.tar.xz", lzma.compress(DATA_TAR, preset=0))
        self.check("data.tar.xz", lzma.compress(DATA_TAR, preset=9))

    def test_control_version_does_not_change_hash(self):
        self.assertEqual(self.hash("data.tar", DATA_TAR, {"control": b"Version: 2\n"}), self.expected)

    def test_maintainer_script_changes_hash(self):
        plain = self.hash("data.tar", DATA_TAR, {"control": b"", "postinst": b"#!/bin/sh\n"})
        setcap = self.hash("data.tar", DATA_TAR, {"control": b"", "postinst": b"#!/bin/sh\nsetcap x\n"})
        self.assertNotEqual(plain, self.expected)
        self.assertNotEqual(plain, setcap)

    def test_no_ar_archive(self):
        path = os.path.join(self.dir, "p.ipk")
        with open(path, "wb") as f:
            f.write(b"something else")
        with self.assertRaises(ValueError):
            build_facts.ipk_sha256(path)


class IpkFilenameTest(unittest.TestCase):
    def test_epoch_is_dropped(self):
        self.assertEqual(build_facts.ipk_filename("kernel-image", "1:6.18.33+git0-r0", "raspberrypi4_64"),
                         "kernel-image_6.18.33+git0-r0_raspberrypi4_64.ipk")

    def test_only_one_character_epoch_is_dropped(self):
        self.assertEqual(build_facts.ipk_filename("p", "10:1.0-r0", "all"), "p_10:1.0-r0_all.ipk")

    def test_without_epoch(self):
        self.assertEqual(build_facts.ipk_filename("dbus-1", "1.16.2-r0", "cortexa72"), "dbus-1_1.16.2-r0_cortexa72.ipk")


class PathTest(unittest.TestCase):
    def test_replace_paths_longest_first(self):
        paths = {"<TMPDIR>": "/b/tmp", "<WORKDIR>": "/b/tmp/work/x"}
        self.assertEqual(
            build_facts.replace_paths("--sysroot=/b/tmp/work/x/sysroot -I/b/tmp/a", paths),
            "--sysroot=<WORKDIR>/sysroot -I<TMPDIR>/a")

    def test_mask_jobs(self):
        self.assertEqual(build_facts.mask_jobs('PARALLELMFLAGS="-j 16" -j8 --no-j 3'),
                         'PARALLELMFLAGS="-j <N>" -j <N> --no-j 3')

    def test_normalize_ws(self):
        self.assertEqual(build_facts.normalize_ws("  a   b\n c "), "a b c")
        self.assertEqual(build_facts.normalize_ws(None), "")

    def test_sorted_words(self):
        self.assertEqual(build_facts.sorted_words(" systemd  message-bus systemd "), ["message-bus", "systemd"])

    def test_sha256_dir_covers_names_and_content(self):
        with tempfile.TemporaryDirectory() as d:
            with open(os.path.join(d, "a.cfg"), "w") as f:
                f.write("CONFIG_A=y\n")
            first = build_facts.sha256_path(d)
            os.rename(os.path.join(d, "a.cfg"), os.path.join(d, "b.cfg"))
            renamed = build_facts.sha256_path(d)
            with open(os.path.join(d, "b.cfg"), "w") as f:
                f.write("CONFIG_A=n\n")
            changed = build_facts.sha256_path(d)
        self.assertEqual(len({first, renamed, changed}), 3)

    def test_sha256_dir_hashes_symlinks_by_target(self):
        with tempfile.TemporaryDirectory() as d:
            os.makedirs(os.path.join(d, "src", "a"))
            os.makedirs(os.path.join(d, "src", "b"))
            os.symlink("a", os.path.join(d, "src", "sub"))
            os.symlink("missing", os.path.join(d, "src", "dangling"))
            first = build_facts.sha256_path(os.path.join(d, "src"))
            os.remove(os.path.join(d, "src", "sub"))
            os.symlink("b", os.path.join(d, "src", "sub"))
            self.assertNotEqual(build_facts.sha256_path(os.path.join(d, "src")), first)


PKGDATA_DBUS_LIB = """PN: dbus
PKG:dbus-lib: libdbus-1-3
FILERPROVIDESFLIST:dbus-lib: /usr/lib/libdbus-1.so.3.38.3
FILERPROVIDES:/usr/lib/libdbus-1.so.3.38.3:dbus-lib:  libdbus-1.so.3(LIBDBUS_1_3)(64bit) libdbus-1.so.3()(64bit)
FILERDEPENDS:/usr/lib/libdbus-1.so.3.38.3:dbus-lib:  libc.so.6(GLIBC_2.34)(64bit) libc.so.6()(64bit)
"""

PKGDATA_AVAHI = """PN: avahi
FILERDEPENDS:/usr/sbin/avahi-daemon:avahi-daemon:  libdbus-1.so.3()(64bit) libc.so.6()(64bit)
"""

PKGDATA_GLIBC = """PN: glibc
FILERPROVIDES:/usr/lib/libc.so.6:glibc:  libc.so.6()(64bit) libc.so.6(GLIBC_2.34)(64bit)
"""


class PkgdataTest(unittest.TestCase):
    def test_parse(self):
        pd = build_facts.parse_pkgdata(PKGDATA_DBUS_LIB + "RRECOMMENDS:dbus-lib:\n")
        self.assertEqual(pd["PN"], "dbus")
        self.assertEqual(pd["PKG:dbus-lib"], "libdbus-1-3")
        self.assertEqual(pd["RRECOMMENDS:dbus-lib"], "")

    def test_parse_manifest(self):
        self.assertEqual(build_facts.parse_manifest("busybox cortexa72 1.37.0-r0\nlibc6 cortexa72 2.42-r0\n\n"),
                         {"busybox": ("cortexa72", "1.37.0-r0"), "libc6": ("cortexa72", "2.42-r0")})

    def test_per_file_deps_drops_version_constraints(self):
        _, depends = build_facts.per_file_deps({"FILERDEPENDS:/usr/bin/a:a": "libfoo (>= 1.0) libc.so.6()(64bit)"})
        self.assertEqual(depends, {"/usr/bin/a": ["libfoo", "libc.so.6()(64bit)"]})

    def test_per_file_deps(self):
        provides, depends = build_facts.per_file_deps(build_facts.parse_pkgdata(PKGDATA_DBUS_LIB))
        self.assertEqual(provides, {"/usr/lib/libdbus-1.so.3.38.3": ["libdbus-1.so.3(LIBDBUS_1_3)(64bit)", "libdbus-1.so.3()(64bit)"]})
        self.assertEqual(list(depends), ["/usr/lib/libdbus-1.so.3.38.3"])

    def test_linked_by(self):
        files = {}
        for text in (PKGDATA_DBUS_LIB, PKGDATA_AVAHI, PKGDATA_GLIBC):
            pd = build_facts.parse_pkgdata(text)
            files[pd["PN"]] = build_facts.per_file_deps(pd)
        self.assertEqual(build_facts.linked_by(files), {
            "dbus": {"/usr/sbin/avahi-daemon": "avahi"},
            "glibc": {"/usr/lib/libdbus-1.so.3.38.3": "dbus", "/usr/sbin/avahi-daemon": "avahi"},
        })

    def test_linked_by_ignores_path_dependencies(self):
        files = {
            "busybox": ({"/bin/busybox.nosuid": ["/usr/bin/env"]}, {}),
            "python3": ({}, {"/usr/bin/script.py": ["/usr/bin/env"]}),
        }
        self.assertEqual(build_facts.linked_by(files), {})

    def test_linked_by_skips_own_files(self):
        pd = build_facts.parse_pkgdata(PKGDATA_GLIBC + "FILERDEPENDS:/usr/bin/ldd:glibc:  libc.so.6()(64bit)\n")
        self.assertEqual(build_facts.linked_by({"glibc": build_facts.per_file_deps(pd)}), {})


class BuiltIntoTest(unittest.TestCase):
    def test_static_chain_and_virtual_provider(self):
        recipes = {
            "lua": {"provides": [], "depends": ["readline"]},
            "lzo": {"provides": [], "depends": []},
            "mtd-utils": {"provides": [], "depends": ["lzo", "zlib-native"]},
            "swupdate": {"provides": [], "depends": ["lua", "mtd-utils", "virtual/libc"]},
            "glibc": {"provides": ["virtual/libc"], "depends": []},
        }
        self.assertEqual(build_facts.built_into(recipes), {
            "lua": ["swupdate"],
            "lzo": ["mtd-utils"],
            "mtd-utils": ["swupdate"],
            "swupdate": [],
            "glibc": ["swupdate"],
        })


class MergeTest(unittest.TestCase):
    def test_check_merge(self):
        facts = {"machine": "raspberrypi4-64", "distro_version": "1"}
        build_facts.check_merge(facts, dict(facts), "initramfs")
        with self.assertRaises(ValueError):
            build_facts.check_merge(facts, {"machine": "genericx86-64", "distro_version": "1"}, "initramfs")

    def test_merge_recipes(self):
        def recipe(packages, linked_by, built_into):
            return {"version": "1", "installed_packages": packages, "linked_by": linked_by, "built_into": built_into}

        image = {
            "glibc": recipe({"libc6": "a"}, {"/usr/bin/x": "x"}, ["x"]),
            "lua": recipe({}, {}, ["swupdate"]),
        }
        initramfs = {
            "glibc": recipe({"ldd": "b", "libc6": "a"}, {"/sbin/parted": "parted"}, ["parted"]),
            "parted": recipe({"parted": "c"}, {}, []),
        }
        self.assertEqual(build_facts.merge_recipes(image, initramfs), {
            "glibc": recipe({"ldd": "b", "libc6": "a"}, {"/sbin/parted": "parted", "/usr/bin/x": "x"}, ["parted", "x"]),
            "lua": recipe({}, {}, ["swupdate"]),
            "parted": recipe({"parted": "c"}, {}, []),
        })


class UnitsTest(unittest.TestCase):
    def test_enabled_units(self):
        with tempfile.TemporaryDirectory() as d:
            os.makedirs(os.path.join(d, "multi-user.target.wants"))
            os.makedirs(os.path.join(d, "sockets.target.requires"))
            os.symlink("/usr/lib/systemd/system/sshd.socket", os.path.join(d, "sockets.target.requires", "sshd.socket"))
            os.symlink("/usr/lib/systemd/system/a.service", os.path.join(d, "multi-user.target.wants", "a.service"))
            with open(os.path.join(d, "local.service"), "w"):
                pass
            self.assertEqual(build_facts.enabled_units(d),
                             ["multi-user.target.wants/a.service", "sockets.target.requires/sshd.socket"])

    def test_missing_dir(self):
        self.assertEqual(build_facts.enabled_units("/nonexistent"), [])


if __name__ == "__main__":
    unittest.main()
