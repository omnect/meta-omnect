# Wifi Commissioning

`omnect-os` can commission Wi-Fi (join a network) over a BLE GATT interface and
a local Unix-socket API, provided by `wifi-commissioning-service`. What gets
**installed** is fixed at build time; what actually **runs** depends on the
adapter present on the unit.

- **Installed** — the package is in the image. Governed by `DISTRO_FEATURES`
  (derived from `MACHINE_FEATURES`). `wifi` is the single gate; there is no
  separate `wifi-commissioning` feature.
- **Runs** — the service is active for a wlan adapter that is present. On
  fixed-hardware devices (currently all supported ARM devices) install and run
  coincide, because the machine knows its adapters. A generic image (x86) ships
  everywhere, so the same build runs or not depending on the unit's hardware.

## What gets installed

| `DISTRO_FEATURES` | pulls in |
| --- | --- |
| `wifi` | `wifi-commissioning-service` (via `omnect-os-image.bb`), which `RDEPENDS` `wpa-supplicant` |
| `bluetooth` | `bluez5` — via `packagegroup-base-bluetooth` and `wifi-commissioning-service`'s `RDEPENDS` |

## What runs, and when

Start is gated on the wlan adapter appearing:

1. A udev rule (`80-wlan-wpa.rules`) starts `wpa_supplicant@<dev>.service` when a
   `wlan*` interface appears (including a hot-plugged USB dongle).
2. `wpa_supplicant@.service` is `BindsTo` the net device, so it is stopped when
   the adapter is removed. There is no static `*.target.wants` enablement.
3. `wpa_supplicant` `Wants` `wifi-commissioning-service@<dev>.service`, so
   commissioning starts with `wpa_supplicant` for that adapter.

A device with no wlan adapter starts nothing until one appears. One
`wpa_supplicant` + commissioning instance runs per `wlan*` interface.

## Bluetooth / BLE

`wifi-commissioning-service` serves a BLE GATT interface and a Unix-socket API.

- **No `bluetooth` feature in the build:** there is no BlueZ, so `--disable-ble`
  is forced and the `bluetooth.service` dependency is stripped.
- **With `bluetooth`:** BLE is enabled. BLE is evaluated once at service start;
  if no controller is present, BLE init fails, the service logs one error and
  keeps serving the Unix-socket API. A BT adapter plugged in later is not picked
  up until the service restarts.

## Per device class

| Class | Example | `wifi` / `bluetooth` | Installed | Runs |
| --- | --- | --- | --- | --- |
| Fixed HW, wifi+BT | Raspberry Pi 4 | yes / yes | yes | always (onboard wifi+BT) |
| Fixed HW, neither | Phygate Tauri-L | no / no | no | — |
| Generic HW (x86) | Welotec Arrakis | yes / yes | yes | per unit — Mk4 (wifi+BT) yes, Pico (no adapters) no |
