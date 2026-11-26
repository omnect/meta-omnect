# Build facts

Each image build writes `build-facts.<image>.json` next to the SBOM
(`bom.json`) in `${DEPLOY_DIR}/dependency-track/`, at the end of
`do_image`. It records, per recipe, the inputs and
outputs a CVE assessment depends on: version, sources, patches, configuration,
installed packages and which parts of the image use the recipe.

The file of one build can be compared with the file of the build on which a
CVE assessment was made. If the facts of a recipe are the same, the build did
not change for that recipe, and an assessment that rests on the build still
applies.

## Recipe set

The file has one entry for every target recipe the SBOM collects for the
image, also for recipes
without a package in the image. Such a recipe can still be part of the image:
swupdate links `liblua.a` and `libmtd.a` statically, so a CVE in lua or
mtd-utils is a CVE in swupdate. Other recipes are only in the SBOM because a
package that is not installed depends on them at runtime. Their entry has no
installed packages and no consumers. Image recipes have no entry.

An image can add the facts of other images that ship with it, such as its
initramfs, by naming them in `DEPENDENCYTRACK_FACTS_MERGE`. The file then has
the recipes of all these images, and the packages, users and consumers of a
recipe are joined, and `images` has an entry per image. The other images
still write their own file. The build fails if a merged file has another
`format_version`, `machine` or `distro_version`. The path of a merged file is
taken from the global `DEPENDENCYTRACK_FACTS`; a setting in the recipe of the
merged image is not seen.

Some recipes put files into the boot partition with `do_deploy` (bootloader,
kernel, firmware). They are marked with `deploys`, and the first check below
does not apply to them or to the recipes built into them.

## Format

```json
{
  "format_version": 1,
  "machine": "raspberrypi4-64",
  "distro_version": "6.0.4.1",
  "recipes": {
    "dbus": {
      "version": "1.16.2",
      "srcrev": {},
      "cve_products": ["d-bus_project:d-bus", "freedesktop:dbus", "freedesktop:libdbus"],
      "packageconfig": ["message-bus", "systemd", "traditional-activation", "user-session"],
      "configure_args": {"EXTRA_OEMESON": "-Dxml_docs=disabled -Ddoxygen_docs=disabled ..."},
      "kconfig": {},
      "src_files": [
        {"name": "dbus-1.init", "sha256": "<sha256>", "patch": false},
        {"name": "run-ptest", "sha256": "<sha256>", "patch": false}
      ],
      "remote_files": [
        {"url": "https://dbus.freedesktop.org/releases/dbus/dbus-1.16.2.tar.xz", "sha256": "<sha256>"}
      ],
      "task_hashes": {"do_compile": "<sha256>", "do_configure": "<sha256>", "do_install": "<sha256>"},
      "installed_packages": {
        "dbus-1": "<sha256>",
        "dbus-common": "<sha256>",
        "dbus-tools": "<sha256>",
        "libdbus-1-3": "<sha256>"
      },
      "linked_by": {"/usr/bin/bluetoothctl": "bluez5", "/usr/sbin/avahi-daemon": "avahi"},
      "built_into": ["avahi", "bluez5", "polkit", "python3-dbus", "wifi-commissioning-service", "wpa-supplicant"]
    },
    "lua": {
      "version": "5.5.0",
      "srcrev": {},
      "cve_products": ["lua"],
      "packageconfig": ["readline"],
      "configure_args": {"EXTRA_OEMAKE": "'CC=aarch64-omnect-linux-gcc ... --sysroot=<WORKDIR>/recipe-sysroot' ..."},
      "kconfig": {},
      "src_files": [{"name": "lua.pc.in", "sha256": "<sha256>", "patch": false}],
      "remote_files": [{"url": "http://www.lua.org/ftp/lua-5.5.0.tar.gz", "sha256": "<sha256>"}],
      "task_hashes": {"do_compile": "<sha256>", "do_configure": "<sha256>", "do_install": "<sha256>"},
      "installed_packages": {},
      "linked_by": {},
      "built_into": ["swupdate"]
    }
  },
  "images": {
    "omnect-os-image": {
      "image_features": ["..."],
      "unit_links": {"default.target": "/usr/lib/systemd/system/multi-user.target", "...": "..."},
      "boot_args": {
        "boot.scr": "setenv bootargs \"root=/dev/${devtype}blk${devnum}p${omnect_os_bootpart} ${bootargs} ${omnect_extra_bootargs} quiet loglevel=3\"",
        "bootfiles/cmdline.txt": "console=tty0 dwc_otg.lpm_enable=0 ... bcm2835-wdt.nowayout=1",
        "omnect_extra_bootargs_omnect": "quiet loglevel=3 systemd.getty_auto=false ..."
      }
    }
  }
}
```

The values are shortened examples. `src_files`, `remote_files` and
`KERNEL_FEATURES` keep the order of the recipe, because patches and config
fragments are applied in that order. All other lists are sorted.

### Recipe fields

| Field | Content |
| --- | --- |
| `version` | `PV` |
| `srcrev` | the revision the fetcher resolved for every `SRC_URI` entry with a revision (git, also for `;rev=`, `;tag=` and `AUTOREV`), by its `name`, or by its URL if it has no name; empty for tarball sources |
| `cve_products` | the `CVE_PRODUCT` entries, as the SBOM component names; joins the recipe with the SBOM components, and one component can belong to several recipes |
| `packageconfig` | final `PACKAGECONFIG` |
| `configure_args` | `EXTRA_OECONF`, `EXTRA_OECMAKE`, `EXTRA_OEMESON`, `CARGO_BUILD_FLAGS` or `GOBUILDFLAGS`, only the one of the build system the recipe uses, plus `EXTRA_OEMAKE` and `CARGO_FEATURES` if set; the paths `WORKDIR`, `TMPDIR`, `TOPDIR`, `COREBASE` and `DL_DIR` replaced by `<WORKDIR>` and so on, the number of make jobs by `-j <N>`, whitespace normalized |
| `kconfig` | kernel only: `KBUILD_DEFCONFIG` and `KERNEL_FEATURES` |
| `src_files` | every local `file://` entry of `SRC_URI` with the sha256 of its content (for a directory: of all its files); `patch` marks the files that are applied as patches |
| `remote_files` | every other entry of `SRC_URI` without a revision (tarballs, remote patches, crates, Go modules) with its parameters and the sha256 from the recipe |
| `task_hashes` | the BitBake basehash of every task that can change the output of the recipe (all tasks except `do_build`, `do_checkuri`, `do_listtasks`, `do_printdiff`, the clean, devshell and Kconfig editing tasks such as `do_menuconfig`, and the QA, SPDX, CVE, license, `rm_work` and dependency-track tasks): the task code and all variables the task uses, without the hashes of the dependencies |
| `deploys` | the image uses files that the recipe deploys: a task of the image depends on its `do_deploy` (boot partition files) |
| `installed_packages` | packages of the recipe in the image manifest, with the sha256 of the uncompressed `data.tar` and the maintainer scripts and `conffiles` of the ipk; the build fails if an ipk is missing |
| `linked_by` | image files of other recipes that link a shared library of the recipe (pkgdata `FILERDEPENDS`), with the recipe of each file |
| `built_into` | target recipes in the recipe set that have this recipe in `DEPENDS` |

`built_into` lists direct consumers only. A chain such as
lzo → mtd-utils → swupdate is followed by the reader.

A new user that loads a library with `dlopen()` or runs a script with an
interpreter (`/bin/sh`, `/usr/bin/python3`) does not change `linked_by` of
that recipe, so the comparison does not see it.

All recipe fields except `installed_packages`, `linked_by` and `built_into`
come from the BitBake data store. They are read for every recipe, also when
the recipe is restored from the sstate cache. Build output such as the final
`.config` is not used, because `do_configure` does not run for a recipe from
the sstate cache.

The configuration of Kconfig recipes (kernel, BusyBox, swupdate) is covered
by other fields: the defconfig and the `.cfg` fragments are in `src_files`,
the `.scc` files of `KERNEL_FEATURES` come from the yocto-kernel-cache, whose
revision is in `srcrev` (`meta`). Options set from variables, such as
BusyBox options from `DISTRO_FEATURES` or `KCONFIG_MODE` of the kernel, are
covered by `task_hashes`.

`task_hashes` covers every input that is a variable or task code: `CFLAGS`,
`FILES`, `RDEPENDS`, `pkg_postinst`, the configure arguments of
`PACKAGECONFIG`, task code from bbappends. It changes as well when a class of
the build system changes, for example after an update of the Yocto layers.
`packageconfig`, `configure_args` and `kconfig` show what changed.

### Image fields

`images` has one entry per image of the file, with these fields:

| Field | Content |
| --- | --- |
| `image_features` | `IMAGE_FEATURES` |
| `unit_links` | every symlink in `/etc/systemd/system` after `IMAGE_PREPROCESS_COMMAND`, with its target: enabled units (`*.wants`, `*.requires`), `default.target` and masked units (`/dev/null`) |
| `boot_args` | the kernel arguments the build sets, by source: the deployed files in `DEPENDENCYTRACK_BOOT_ARGS_FILES` (the `setenv bootargs` lines of a U-Boot script, else the whole text) and the variables in `DEPENDENCYTRACK_BOOT_ARGS_VARS` |

`boot_args` keeps the parts as they are; the bootloader puts them together
when the device boots. Arguments that the firmware adds, that come from a
device tree of the kernel, or that are set on the device
(`omnect_extra_bootargs_custom`) are not in the file.

## Comparing two builds

Compare only files of the same image built with the same configuration. A
different distro feature can change `task_hashes` of most recipes,
even when their packages are equal.

A recipe has the same facts in two builds if one of the two checks passes.

1. **Same binaries:** no recipe along the `built_into` chain, the recipe
   itself included, has `deploys`; the recipe or a recipe along the chain has
   installed packages; and these are equal:
   - `installed_packages`, names and hashes
   - the recipes in `linked_by`
   - `installed_packages` of every recipe in `built_into`, followed
     transitively

   The build sets `SOURCE_DATE_EPOCH`, so the same input gives the same
   package hash. This check also covers recipes without own packages, such as lua.
2. **Same inputs:** if the binaries differ, for example after a compiler
   update, these fields are equal: `version`, `srcrev`, `cve_products`,
   `src_files` (names and hashes, in order), `remote_files`, `task_hashes`,
   `deploys`, the names in `installed_packages`, the recipes in `linked_by`,
   and `built_into`.

The file paths in `linked_by` are not compared: a library such as glibc
often gets a new user binary, but rarely a new user recipe.

A recipe that is missing in one of the two files does not have the same
facts.

An SBOM component can belong to several recipes: `gcc` is in
`cve_products` of libgcc and gcc-runtime, the SBOM lists it once. The
assessment of a component applies only if every recipe in either file with the
component in `cve_products` has the same facts.

The image fields are compared only when an assessment depends on them, per
image.
