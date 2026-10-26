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
| `no` | the capability is not available, either because the hardware is absent or because it is deliberately not used |
| `optional` | the hardware may be present on an individual device |
| `yes` | the hardware is present on every device of this class |

`optional` and `yes` are identical at build time; they differ only on the device.

What the value controls depends on the capability:

| Capability | Effect of the value |
| --- | --- |
| `bluetooth`, `wifi` | drives the `DISTRO_FEATURE` of the same name, and is read on the device |
| `3g`, `tpm2` | only checked against `MACHINE_FEATURES` |

For `wifi` and `bluetooth` the build-time file is an upper bound: `no` keeps the
support out of the image, so editing the installed copy cannot enable it
afterwards. `optional` and `yes` both build it in, and the installed copy decides
what is started.

For `3g` and `tpm2` the value changes nothing in the build. Their
`DISTRO_FEATURES` follow `MACHINE_FEATURES` instead, so a machine with
`"tpm2": "no"` and `tpm2` in `MACHINE_FEATURES` still gets the full TPM support,
and nothing on the device reads these two values. For them the entry is a
declaration that is kept consistent with `MACHINE_FEATURES`, nothing more.

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

Without that, the configuration parses, but parsing `base-files` aborts
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
matching `MACHINE_FEATURES` entry; for `wifi` and `bluetooth` the userspace stack
would otherwise be installed with no driver behind it, for `3g` and `tpm2` the two
would simply state different things.

`recipes-omnect/images/omnect-os-image.bb` checks this per machine and aborts the
build when they disagree. It applies the same rule to `DISTRO_FEATURES`, which
catches a feature added by a `DISTRO_FEATURES:append` in a layer or in
`local.conf` on a machine whose `MACHINE_FEATURES` do not carry it.

The reverse is allowed: a machine may have the hardware in `MACHINE_FEATURES` and
still set the capability to `no`, which is how a device class is shipped with
hardware that is deliberately not used.

## Reading a capability during the build

`conf/distro/include/omnect-os-distro.conf` defines one variable per capability:

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

`/etc/omnect/device_caps.json` is read by
`omnect-wifi-commissioning-start.sh`, which looks at `wifi` and `bluetooth` to
decide what to start; see [wifi commissioning](wifi_commissioning.md). No other
component reads the file, so `3g` and `tpm2` have no effect on the device. The
file may be adapted per device, so a device class shipped with `wifi` or
`bluetooth` set to `optional` can be narrowed down for an individual unit without
a rebuild.
