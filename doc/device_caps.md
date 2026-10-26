# Device capabilities

A device capability describes what a device class can offer in hardware. The
capabilities of a `MACHINE` are declared in a flat JSON file,
`files/device_caps/${MACHINE}.json`, which is both evaluated during the build and
installed on the device as `/etc/omnect/device_caps.json`.

```json
{"3g": "no", "bluetooth": "yes", "tpm2": "optional", "wifi": "yes"}
```

## Capabilities and values

| Capability | Hardware |
| --- | --- |
| `3g` | LTE/3G modem |
| `bluetooth` | Bluetooth controller |
| `tpm2` | TPM 2.0 chip |
| `wifi` | Wi-Fi adapter |

Every capability takes one of three values:

| Value | Meaning |
| --- | --- |
| `no` | the device class never has this hardware |
| `optional` | the hardware may be present on an individual device |
| `yes` | the hardware is present on every device of this class |

`optional` and `yes` are identical at build time — both build and install the
support. They differ only at runtime, where the installed
`/etc/omnect/device_caps.json` decides what is actually used. The build-time file
is therefore an upper bound: a capability set to `no` is not built into the image,
so editing the installed file cannot enable it afterwards.

## Where the file is looked up

The file is resolved twice, by two independent mechanisms, and both have to find it:

- **Build configuration** — `get_cap()` in `lib/omnect/device_caps.py` searches
  `files/device_caps/${MACHINE}.json` in every layer listed in `BBLAYERS` and takes
  the first match.
- **Installed copy** — `recipes-core/base-files/base-files_%.bbappend` resolves the
  file over `FILESEXTRAPATHS`, not over `BBLAYERS`. The bbappend prepends
  `${LAYERDIR_omnect}/files/device_caps`, so meta-omnect's copy wins whenever it
  exists, whatever the `BBLAYERS` order is.

A layer other than meta-omnect that provides the file must therefore also add its
own directory for `base-files`, in its machine conf:

```
FILESEXTRAPATHS:prepend:pn-base-files := "${LAYERDIR_<layer>}/files/device_caps:"
```

Without that, the build configures correctly, but `base-files` fails in `do_fetch`
because it cannot find `${MACHINE}.json`. Keep a machine's file in exactly one
layer: if meta-omnect carries it as well, the build configuration follows the
`BBLAYERS` match while the installed file is the meta-omnect one, and build time
and runtime can disagree.

## Validation

Every `MACHINE` needs the file, and it must set all capabilities listed above to a
valid value. A missing file, a missing capability or any other value aborts the
parse in `lib/omnect/device_caps.py`. Keys that are not capabilities are ignored,
so an entry such as `"_comment"` may be used to explain a setting.

## MACHINE_FEATURES has to agree

The capabilities do not control the kernel side. Drivers and firmware come from the
BSP through `MACHINE_FEATURES`, whose entries carry the same names as the
capabilities. A capability set to `optional` or `yes` therefore requires the
matching `MACHINE_FEATURES` entry; otherwise the userspace stack is installed with
no driver behind it. `recipes-omnect/images/omnect-os-image.bb` checks this per
machine and aborts the build when they disagree.

## Reading a capability during the build

`conf/distro/include/omnect-os-distro.conf` exports one variable per capability:

| Capability | Variable |
| --- | --- |
| `3g` | `OMNECT_DEVICE_CAP_3G` |
| `bluetooth` | `OMNECT_DEVICE_CAP_BLUETOOTH` |
| `tpm2` | `OMNECT_DEVICE_CAP_TPM2` |
| `wifi` | `OMNECT_DEVICE_CAP_WIFI` |

Recipes must read a capability through its variable and never call `get_cap()` from
task code. Only the variable's `[vardepvalue]` flag puts the JSON value into the
task signature; a task calling `get_cap()` directly hashes just the function source
and `MACHINE`, and would still be served from sstate after a capability changed.

Not every capability drives a `DISTRO_FEATURE` from its value. `wifi` and
`bluetooth` do, in `omnect-os-distro.conf`. The `3g` and `tpm2` `DISTRO_FEATURES`
are derived from `MACHINE_FEATURES` instead, in `omnect-os-distro.conf` and in
`conf/distro/include/omnect-os-user_classes.conf`.

## Runtime

`/etc/omnect/device_caps.json` is read by the device software to decide what to
start; see [wifi commissioning](wifi_commissioning.md) for the `wifi` and
`bluetooth` case. The file may be adapted per device, so a device class shipped
with a capability set to `optional` can be narrowed down or switched on for an
individual unit without a rebuild.
