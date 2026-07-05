# Document the install/run logic of bluez, wpa_supplicant & wifi-commissioning

**Date:** 2026-07-05
**Status:** Draft for review
**Type:** Documentation (maintainer reference)

## Problem

After the `wifi-commissioning` DISTRO_FEATURE removal (meta-omnect PR #664), the
rules that decide **whether** `bluez5`, `wpa_supplicant`, and
`wifi-commissioning-service` are *installed*, and **whether/when** they *run*,
are spread across several recipes, a udev rule, a systemd unit, and a drop-in.
Nothing explains the reasoning in one place, so a future change (e.g. touching
`IMAGE_POSTPROCESS_COMMAND`, the udev rule, or the `--disable-ble` logic) could
break it without the author realising the intent.

Goal: a **concise maintainer reference** capturing the logic and dependencies —
device-independent explanation in one topic doc, device-specific facts in the
existing per-device docs.

## Decisions (confirmed)

1. **Approach A:** one topic doc for the shared logic; per-device docs stay thin
   (their capability row + a link). Not the alternative of scattering the logic
   across device docs.
2. Keep it **concise** — explain the logic and dependency chains, not every
   recipe line.
3. Include a **mermaid diagram** of the install + runtime flow.
4. **Adapt `WELOTEC.md`** (Arrakis Series) to reflect its two variants (Mk4 has
   wifi+BT, Pico has neither) — the textbook "installed but only runs where the
   hardware exists" case.
5. Add a link from **README.md** under `## Features`.

## Facts to document (verified in-tree)

**Install (build time):**
- `MACHINE_FEATURES wifi` → `DISTRO_FEATURES wifi`
  (`conf/distro/include/omnect-os-distro.conf`).
- `DISTRO_FEATURES wifi` → `omnect-os-image.bb` installs
  `wifi-commissioning-service`, which `RDEPENDS` `wpa-supplicant`.
- `MACHINE_FEATURES bluetooth` → `DISTRO_FEATURES bluetooth` → `bluez5`, pulled
  two ways: OE `packagegroup-base-bluetooth` (via `COMBINED_FEATURES bluetooth`)
  and `wifi-commissioning-service` `RDEPENDS bluez5 (>=5.60)` when `bluetooth`
  is set.

**Run (runtime), universal:**
- udev rule `80-wlan-wpa.rules`: on `wlan*` add →
  `ENV{SYSTEMD_WANTS}+="wpa_supplicant@%k.service"`.
- `wpa_supplicant@.service`: `BindsTo=sys-subsystem-net-devices-%i.device`
  (starts when the adapter appears incl. hot-plug, stops when it goes away) and
  `Wants=wifi-commissioning-service@%i.service`.
- `wifi-commissioning-service@.service` `Requires=` its `@.socket`. No static
  `*.target.wants` symlinks — the udev event is the only trigger.

**BLE (`--disable-ble`) decision:**
- Build time: when `DISTRO_FEATURES` lacks `bluetooth`, the recipe strips the
  `bluetooth.service` dependency and forces `--disable-ble` via a drop-in
  `Environment=` (no bluez → BLE impossible).
- Runtime: otherwise the drop-in `10-omnect-runtime.conf` probes
  `/sys/class/bluetooth/hci*` and adds `--disable-ble` when no adapter is
  present (operator override via `WIFI_COMMISSIONING_EXTRA_ARGS`).
- The service binary self-degrades: if BLE fails to start it logs one error and
  keeps serving the Unix-socket API.

**The principle (the doc's backbone):** *exists* (package in the image) is
governed by `DISTRO_FEATURES`; *runs* (service active, BLE on) is governed by
the physical adapter present on that specific unit. They **converge on fixed
hardware** (ARM: the machine knows its adapters) and **diverge on generic
hardware** (x86: same image, per-unit hardware varies).

## Deliverable

### 1. New `doc/wifi_commissioning.md` (device-independent)

Sections (concise):
1. **Overview** — one paragraph: single `wifi` gate; adapter-gated at runtime;
   BLE decided from real BT presence.
2. **What gets installed** — the feature→package chains above (short list).
3. **What runs, and when** — the udev + `BindsTo` + `Wants` cascade; no static
   enablement; teardown on adapter removal.
4. **Bluetooth / BLE** — build-time force vs runtime probe; graceful degradation.
5. **exists vs runs** — the principle, with the per-device-class table:

   | Class | Example | `wifi`/`bt` features | Installed | Runs |
   |-------|---------|----------------------|-----------|------|
   | Fixed HW, wifi+BT | rpi4 | yes / yes | yes | always (onboard) |
   | Fixed HW, neither | tauri | no / no | no | n/a |
   | Generic HW (x86) | Arrakis | yes / yes | yes | per-unit: Mk4 yes, Pico no |

6. **Mermaid diagram** (draft — the plan transcribes verbatim):

   ```mermaid
   flowchart TD
     MF["MACHINE_FEATURES"] -->|wifi| DFW["DISTRO_FEATURES: wifi"]
     MF -->|bluetooth| DFB["DISTRO_FEATURES: bluetooth"]
     DFW -->|install| WCS["wifi-commissioning-service"]
     WCS -->|RDEPENDS| WPA["wpa-supplicant"]
     DFB -->|packagegroup-base-bluetooth + RDEPENDS| BZ["bluez5"]

     UDEV["udev: wlan* added"] -->|SYSTEMD_WANTS| WPAU["wpa_supplicant@wlanN.service<br/>BindsTo net device"]
     WPAU -->|Wants| SVC["wifi-commissioning-service@wlanN.service"]
     SVC -->|Requires| SOCK["@wlanN.socket"]
     SVC --> BLE{"/sys/class/bluetooth/hciN present?"}
     BLE -->|yes| BLEON["BLE enabled"]
     BLE -->|no| BLEOFF["--disable-ble (Unix socket only)"]
   ```

   (If `DISTRO_FEATURES` lacks `bluetooth`, `--disable-ble` is forced at build
   time and the `bluetooth.service` dependency is stripped — note in prose.)

7. **Where to change what** — a short pointer list: install gate =
   `omnect-os-image.bb`; runtime gate = `wpa_supplicant@.service` +
   `80-wlan-wpa.rules`; BLE = `wifi-commissioning-service.inc` +
   `10-omnect-runtime.conf`.

### 2. Per-device doc edits

- `doc/RASPBERRY-PI.md` (rpi4): capability row stays **yes**; add a link to
  `wifi_commissioning.md`.
- `doc/PHYTEC.md` (tauri): row stays **no** (no `wifi` feature); add the link.
- `doc/WELOTEC.md` (Arrakis Series): **adapt** the "Wifi Commissioning via
  Bluetooth" row so it distinguishes the variants — commissioning is *installed*
  (x86 image) and runs only where the hardware exists: **Mk4 = yes (wifi+BT)**,
  **Pico = no (no wifi/BT adapter)**. Add the link. (Values sourced from
  `omnect-os/ci/test_devices/dut16_arrakis-mk4.yaml` = wifi 1 / bt 1 and
  `dut8_arrakis-pico.yaml` = wifi 0 / bt 0.)

### 3. `README.md`

Add a bullet under `## Features` linking `doc/wifi_commissioning.md`, matching
the style of the existing `efi_secure_boot.md` / `mac_lsm.md` entries.

## Out of scope

- Secure-boot / initramfs signing (separate topic, `efi_secure_boot.md`).
- The `wifi-commissioning-service` binary internals (upstream repo).
- Changing any runtime behaviour — this is documentation only.

## Testing / verification

- `doc/wifi_commissioning.md` renders (mermaid block valid) and every stated
  fact matches the recipes on the `chore` branch (PR #664).
- Links resolve: README → topic doc, and each per-device doc → topic doc.
- WELOTEC.md variant capabilities match the two DUT yaml files.
