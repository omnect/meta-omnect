# Build facts

The image build writes `build-facts.json` next to the SBOM (`bom.json`) in
`${DEPLOY_DIR}/dependency-track/`. It records, per recipe, the inputs and
outputs a CVE assessment depends on: version, sources, patches, configuration,
installed packages and which parts of the image use the recipe.

The file of one build can be compared with the file of the build on which a
CVE assessment was made. If the facts of a recipe are the same, the build did
not change for that recipe, and an assessment that rests on the build still
applies.

## Recipe set

The file has one entry for every target recipe in the SBOM, also for recipes
without a package in the image. Such a recipe can still be part of the image:
swupdate links `liblua.a` and `libmtd.a` statically, so a CVE in lua or
mtd-utils is a CVE in swupdate. Other recipes are only in the SBOM because a
package that is not installed depends on them at runtime. Their entry has no
installed packages and no consumers.

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
      "configure_args": {"EXTRA_OEMAKE": "'CC=aarch64-omnect-linux-gcc ... --sysroot=${WORKDIR}/recipe-sysroot' ..."},
      "kconfig": {},
      "src_files": [{"name": "lua.pc.in", "sha256": "<sha256>", "patch": false}],
      "installed_packages": {},
      "linked_by": {},
      "built_into": ["swupdate"]
    }
  },
  "image": {
    "image_features": ["..."],
    "enabled_units": ["..."],
    "kernel_cmdline": "..."
  },
  "crates": {
    "tokio@1.54.1": {"recipe": "omnect-device-service", "cargo_lock_sha256": "<sha256>"}
  }
}
```

The values are shortened examples. All lists are sorted.

### Recipe fields

| Field | Content |
| --- | --- |
| `version` | `PV` |
| `srcrev` | revision of every git entry in `SRC_URI`, by its `name`; empty for tarball sources |
| `cve_products` | the `CVE_PRODUCT` entries, as the SBOM component names; the key to join with the SBOM |
| `packageconfig` | final `PACKAGECONFIG` |
| `configure_args` | `EXTRA_OECONF`, `EXTRA_OECMAKE` or `EXTRA_OEMESON`, only the one of the build system the recipe uses, plus `EXTRA_OEMAKE` if set; build paths replaced by placeholders, whitespace normalized |
| `kconfig` | kernel only: `KBUILD_DEFCONFIG` and `KERNEL_FEATURES` |
| `src_files` | every local `file://` entry of `SRC_URI` with the sha256 of its content (for a directory: of all its files); `patch` marks the files that are applied as patches |
| `installed_packages` | packages of the recipe in the image, with the sha256 of the uncompressed `data.tar` of the ipk |
| `linked_by` | image files of other recipes that link a library of the recipe dynamically, with the recipe of each file |
| `built_into` | target recipes in the recipe set that have this recipe in `DEPENDS` |

`built_into` lists direct consumers only. A chain such as
lzo → mtd-utils → swupdate is followed by the reader.

All recipe fields except `installed_packages`, `linked_by` and `built_into`
come from the BitBake data store. They are read for every recipe, also when
the recipe is restored from the sstate cache. Build output such as the final
`.config` is not used, because `do_configure` does not run for a recipe from
the sstate cache.

The configuration of Kconfig recipes (kernel, BusyBox, swupdate) is covered
by other fields: the defconfig and the `.cfg` fragments are in `src_files`,
the `.scc` files of `KERNEL_FEATURES` come from the yocto-kernel-cache, whose
revision is in `srcrev` (`meta`).

### Image fields

| Field | Content |
| --- | --- |
| `image_features` | `IMAGE_FEATURES` |
| `enabled_units` | systemd units enabled in the rootfs |
| `kernel_cmdline` | the final kernel command line |

### Crates

Rust crates come from the CycloneDX SBOMs of the Rust services in the image,
not from recipes. `crates` maps each `<name>@<version>` to the recipe that
builds it and holds the sha256 of that recipe's `Cargo.lock`. The code of a
crate is part of the packages of that recipe.

## Comparing two builds

A recipe has the same facts in two builds if one of the two checks passes.

1. **Same binaries:** these are equal:
   - `installed_packages`, names and hashes
   - the recipes in `linked_by`
   - `installed_packages` of every recipe in `built_into`, followed
     transitively

   The build sets `SOURCE_DATE_EPOCH`, so the same input gives the same
   package hash.
   This check also covers recipes without own packages, such as lua.
2. **Same inputs:** if the binaries differ, for example after a compiler
   update, these fields are equal: `version`, `srcrev`, `cve_products`,
   `packageconfig`, `configure_args`, `kconfig`, `src_files` (names and
   hashes), the names in `installed_packages`, the recipes in `linked_by`,
   and `built_into`.

The file paths in `linked_by` are not compared: a library such as glibc
often gets a new user binary, but rarely a new user recipe.

A recipe that is missing in one of the two files does not have the same
facts. A crate has the same facts if its version is the same and its recipe
has the same facts.

The image fields are compared only when an assessment depends on them.
