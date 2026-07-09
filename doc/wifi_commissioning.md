# Wifi Commissioning

`omnect-os` can commission Wi-Fi (join a network) over a BLE GATT interface and
a local Unix-socket API, provided by `wifi-commissioning-service` (wcs).

The single source of truth is `/etc/omnect/device_caps.json`, a flat per-machine
JSON file. Two keys control this feature:

- `wifi` — `no` | `optional` | `yes`
- `bluetooth` — `no` | `optional` | `yes`

The same file drives both **what is installed/compiled** (build time) and
**what actually starts** (runtime). The interface is assumed to be `wlan0`.

## Build time: install and compile

`DISTRO_FEATURES` `wifi` and `bluetooth` are derived from `device_caps.json`
for the target `MACHINE` (see `conf/distro/include/omnect-os-distro.conf`; the
values are validated in `recipes-omnect/images/omnect-os-image.bb`). `bluetooth`
is gated on `wifi`: it is only set when `wifi` is also enabled.

| `device_caps` value | `DISTRO_FEATURES` |
| --- | --- |
| `wifi` is `optional` or `yes` | `wifi` is set |
| `wifi` is `optional` or `yes` **and** `bluetooth` is `optional` or `yes` | `bluetooth` is also set |
| `wifi` is `no` | neither `wifi` nor `bluetooth` is set |

`wifi` and `bluetooth` are standard OE-core/meta-oe `DISTRO_FEATURES`, so setting
them also pulls in their usual upstream effects (wpa-supplicant, bluez5, kernel
config, and so on). On top of those, meta-omnect adds:

- `wifi`: installs `wifi-commissioning-service` and the `omnect-wifi-commissioning`
  oneshot in the image.
- `bluetooth` (only reachable when `wifi` is also set): compiles
  `wifi-commissioning-service` with the `ble` cargo feature.

`optional` and `yes` are treated identically at build time — both install and
compile the same bits. Only runtime behavior differs between them.

## MACHINE_FEATURES and device_caps must agree

`device_caps.json` controls install and runtime behavior through `DISTRO_FEATURES`
`wifi` and `bluetooth`. It does not control the kernel side. The kernel wifi/
bluetooth driver and firmware still come from the BSP, through `MACHINE_FEATURES`.

The two must agree per machine. A machine whose `device_caps` enables `wifi` or
`bluetooth` must also have the matching `MACHINE_FEATURES`. If not, the build
fails: `omnect-os-image.bb` checks this and aborts with `bb.fatal` when
`device_caps` turns on `wifi` or `bluetooth` that `MACHINE_FEATURES` does not have.

Setting `device_caps` to a capability the machine has no `MACHINE_FEATURES` for
does not add a driver. The userspace stack (wpa_supplicant, wcs) would install,
but the hardware has no driver, so it cannot work.

## Activating an `optional` capability before first boot

Because `optional` and `yes` produce the same image, a device shipped with
`wifi: "optional"` can be activated by injecting an overwritten
`/etc/omnect/device_caps.json` with the value set to `"yes"` before the device's
first boot. No rebuild is needed — the oneshot described below picks up the
edited value at boot.

## Runtime: what starts

At boot, the `omnect-wifi-commissioning` oneshot service reads
`/etc/omnect/device_caps.json`:

- `wifi == "yes"`: it starts `wpa_supplicant@wlan0.service`, which in turn pulls
  in `wifi-commissioning-service` via its `Wants=`.
- `wifi` is `"no"` or `"optional"`: the oneshot exits without starting anything.
  wpa_supplicant and wcs stay installed but inactive.
- `bluetooth == "yes"` (only with `wifi == "yes"`): wcs is started with BLE enabled.
- `bluetooth` is `"no"` or `"optional"`: BLE stays off (it also defaults off in
  the binary).

The oneshot always targets `wlan0` and runs once at boot, so a machine whose
`device_caps.wifi` is `"yes"` must have a working `wlan0` present at boot.

## Bluetooth / BLE

`wifi-commissioning-service` serves a BLE GATT interface in addition to its
Unix-socket API. BLE support is a compile-time cargo feature (`ble`), gated on
`DISTRO_FEATURES bluetooth`, and its activation is a runtime flag
(`--enable-ble`), gated on `device_caps.bluetooth == "yes"`. These are two
separate decisions:

| `device_caps.bluetooth` | build: `ble` compiled? | runtime wcs arg | BLE state |
| --- | --- | --- | --- |
| `no` | no | (none) | off |
| `optional` | yes | (none) | off (default) |
| `yes` | yes | `--enable-ble` | on |

Because BLE defaults off in the binary and only turns on with the explicit
`--enable-ble` flag, editing `bluetooth` down to `optional`/`no` before first
boot cannot accidentally leave BLE enabled.

## Per device class

| Class | Example | `wifi` / `bluetooth` | Installed | Runs |
| --- | --- | --- | --- | --- |
| Fixed HW, wifi+BT | Raspberry Pi 4 | yes / yes | yes | wpa_supplicant + wcs (BLE on) |
| Fixed HW, neither | Phygate Tauri-L | no / no | no | — |
| Generic HW (x86) | Welotec Arrakis | optional / optional | yes | inactive until `device_caps.json` is set to `yes` on units that have a wlan/BT adapter |
