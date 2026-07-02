# Remove the `wifi-commissioning` DISTRO_FEATURE

**Date:** 2026-07-02
**Status:** Draft for review

## Problem

Today wifi commissioning is gated by a dedicated `DISTRO_FEATURE`
(`wifi-commissioning`) that is set opt-in via
`meta-omnect/kas/example/wifi-commissioning.yaml`. This means two independent
switches (`wifi` and `wifi-commissioning`) control closely related
functionality, and the commissioning service is only ever enabled where the
example KAS file is explicitly included.

We want a single gate: **`DISTRO_FEATURES` `wifi` is the only switch.** Any image
built for wifi installs and runs the commissioning service.

This surfaces a hardware-knowledge problem the old design hid:

- On **fixed-hardware (ARM)** machines the presence of a wifi/BT adapter is
  known at build time via `MACHINE_FEATURES`. Build-time gating is sufficient.
- On **generic-hardware (x86)** machines the actual adapters are unknown at
  build time. `genericx86-64.extra.conf` declares `wifi` and `bluetooth` in
  `MACHINE_FEATURES` to cover the possibility, so the packages are always
  installed — but a given box may have no wifi adapter, no BT adapter, or a
  hot-plugged USB dongle. So on generic hardware the *start* of the services
  and the BLE decision must be made at runtime.

## Decisions (confirmed with requester)

1. **Fully always-on with `wifi`.** The `wifi-commissioning` feature is removed
   entirely. Every wifi image installs and runs the commissioning service.
   Accepted consequence: this widens the security surface — every wifi device
   now exposes a BLE GATT interface plus a local Unix-socket reconfig API. There
   is intentionally no way to ship wifi without commissioning.
2. **No per-board branching.** Runtime gating is universal (works correctly on
   both fixed and generic hardware), so recipes do not branch on machine name or
   a "generic hardware" flag.
3. **Single adapter gate on `wpa_supplicant` (option A).** `wpa_supplicant` is
   the unit that owns the wlan device; the commissioning service rides along via
   a forward `Wants=` from `wpa_supplicant`.
4. **Runtime BT handling via `ExecStartPre` + env file.** The `--disable-ble`
   decision moves from build time to service start, driven by real adapter
   presence. No change to the upstream `wifi-commissioning-service` binary.

## Background: what the binary already does

`wifi-commissioning-service` (github.com/omnect/wifi-commissioning-service, the
recipe's actual source — *not* the legacy `wifi-commissioning-gatt-service`)
already tolerates a missing BT adapter: it tries `default_adapter()` once at
startup and, on failure, logs one error and keeps running because the Unix
socket transport stays up (`main.rs:88-103`). It does **not** poll/retry for a
hot-plugged adapter. `--disable-ble` is a real runtime CLI flag (`cli.rs`).

So we need no binary change. Runtime BT handling is only about (a) avoiding the
error log when there is no BT hardware and (b) enabling BLE only when a BT
adapter is actually present.

## Design

### 1. Install gate — build time, both platforms

`recipes-omnect/images/omnect-os-image.bb`: change the install gate from
`wifi-commissioning` to `wifi`.

```
${@bb.utils.contains('DISTRO_FEATURES', 'wifi', ' wifi-commissioning-service', '', d)} \
```

`wpa-supplicant` continues to be pulled in transitively via the commissioning
service's `RDEPENDS`. On x86 both are always installed (MACHINE_FEATURES `wifi`);
on ARM they are installed only where the machine declares `wifi` (rpi4 yes,
tauri no). This satisfies Q1 and Q4.

### 2. Start gate — runtime, universal (option A)

The robust "start when the adapter appears, stop when it goes away, handle
hot-plug" pattern is device-activation via udev + `BindsTo`, applied to
`wpa_supplicant` as the single entry point.

- **New udev rule** (installed by the wpa-supplicant bbappend):

  ```
  SUBSYSTEM=="net", KERNEL=="wlan*", ACTION=="add", TAG+="systemd", \
    ENV{SYSTEMD_WANTS}+="wpa_supplicant@%k.service"
  ```

- **`wpa_supplicant@.service`** — replace the weak
  `Requires=sys-subsystem-net-devices-%i.device` + `ConditionPathExists`
  (the unit's own comment calls the condition "no real benefit") with:

  ```
  BindsTo=sys-subsystem-net-devices-%i.device
  After=sys-subsystem-net-devices-%i.device
  Wants=wifi-commissioning-service@%i.service
  ```

- **Drop all static enablement symlinks**: `wpa_supplicant@wlan0.service` in
  `multi-user.target.wants`, and both commissioning symlinks
  (`multi-user.target.wants/...@wlan0.service`,
  `sockets.target.wants/...@wlan0.socket`). The udev rule becomes the only
  trigger.

**Cascade:**
`wlan* add` → udev pulls `wpa_supplicant@wlan0` (bound to the device) →
`Wants` pulls `wifi-commissioning-service@wlan0.service` (continuous, for BLE
advertising) → its existing `Requires=wifi-commissioning-service@wlan0.socket`
pulls the socket (which creates the listen fd the service inherits via
`listenfd`). On adapter removal, `BindsTo` stops `wpa_supplicant`; because the
commissioning service `Requires=`+`After=` `wpa_supplicant`, stopping
`wpa_supplicant` tears the commissioning service down too.

On ARM the wlan device is always present, so the cascade fires at boot exactly
like today's static enablement — behaviour is unchanged in practice (Q4). On
x86 nothing starts without an adapter, and a hot-plugged dongle triggers the
cascade (Q2).

Note the accepted coupling (option A): the generic `wpa_supplicant@.service`
now names the commissioning unit. A `Wants=` on a not-installed unit is
non-fatal, but in this always-on design the two are always installed together.

### 3. BT handling — runtime `--disable-ble`, universal

Two parts, split by concern:

- **Build time (keyed on `DISTRO_FEATURES bluetooth` = is bluez installed):**
  keep stripping `Requires=bluetooth.service` / `After=bluetooth.service` from
  the commissioning unit when bluetooth is absent, so the unit never references a
  non-existent `bluetooth.service`. This stays in
  `wifi-commissioning-service.inc`.

- **Runtime (universal ExecStart override drop-in):** the build-time
  `--disable-ble` append is removed and replaced by a runtime probe.
  - Ship a systemd drop-in
    (`wifi-commissioning-service@.service.d/10-omnect-runtime.conf`) that resets
    and overrides `ExecStart` with an inline BT probe:
    `ls /sys/class/bluetooth/hci*` → add `--disable-ble` when no adapter.
  - Operator override is preserved: the inline logic uses
    `WIFI_COMMISSIONING_EXTRA_ARGS` from the existing
    `EnvironmentFile=-/etc/omnect/wifi-commissioning-service.env` when set, and
    only auto-detects when it is empty.

  > Note: an earlier idea (`ExecStartPre` writing a generated env file read via
  > `EnvironmentFile=`) does **not** work — systemd reads `EnvironmentFile=` once
  > at service start, before `ExecStartPre` runs, so the written value is never
  > picked up by `ExecStart`. The inline drop-in avoids this ordering trap.

Result: BLE runs only when BT hardware is actually present, on every platform,
with no error spam and no upstream binary change. On fixed hardware (rpi4) the
probe always finds `hci*` → BLE enabled, matching the old build-time result. On
tauri the service is not installed, so this is moot.

### 4. bluez5 restart workaround (rpi dynamic layer)

`dynamic-layers/raspberrypi/recipes-connectivity/bluez5/bluez5_%.bbappend`
patches `bluetooth.service` to be `PartOf=wifi-commissioning-service@wlan0.service`
(workaround for a bluez advertising registration bug). Re-key its guard from
`wifi-commissioning` to `wifi`; the patch itself is unchanged.

### 5. Remove the opt-in KAS example

Delete `meta-omnect/kas/example/wifi-commissioning.yaml`.

## Cross-repo changes

### meta-omnect
- `recipes-omnect/images/omnect-os-image.bb` — install gate → `wifi`.
- `recipes-connectivity/wpa-supplicant/wpa-supplicant_%.bbappend` — add udev
  rule to `SRC_URI` + install; stop creating the `multi-user.target.wants`
  symlink.
- `recipes-connectivity/wpa-supplicant/wpa-supplicant/wpa_supplicant@.service`
  — `BindsTo` device, `Wants` commissioning service, drop weak
  `Requires`/`ConditionPathExists`.
- new file: udev rule (e.g.
  `recipes-connectivity/wpa-supplicant/wpa-supplicant/80-wlan-wpa.rules`).
- `recipes-omnect/wifi-commissioning-service/wifi-commissioning-service.inc` —
  remove the `wifi-commissioning`-requires-`wifi` python sanity check; stop
  creating static symlinks; rewrite `ExecStart` for extra args; add root
  `ExecStartPre` BT probe + generated env file; keep the build-time
  `bluetooth.service` dependency strip; drop the build-time `--disable-ble`
  append.
- delete `kas/example/wifi-commissioning.yaml`.
- `dynamic-layers/raspberrypi/recipes-connectivity/bluez5/bluez5_%.bbappend` —
  re-key guard `wifi-commissioning` → `wifi`.
- `recipes-core/systemd/systemd_%.bbappend` — no change (wlan network/link
  install stays keyed on `MACHINE_FEATURES wifi`).

### omnect-os
- `ci/machine/{rpi4,rpi4-omnect-lab,rpi3,polis4}.yaml` — remove the
  `meta-omnect/kas/example/wifi-commissioning.yaml` include.
- `ci/tests/base_test.sh` — `test_distro_feature_wifi_commissioning` re-keys
  from `wifi-commissioning` to `wifi`. Because start is now adapter-gated, the
  test must also account for adapter presence (e.g. `TEST_USES_WIFI`): expect
  `is-active` only when a wlan adapter exists; otherwise expect the service
  inactive rather than failed.
- `doc/legal/*.md` — drop `wifi-commissioning.yaml` references.
- Stale legacy `wifi-commissioning-gatt` artifacts (syslog whitelists,
  `omnect-os/gen` download) — flag for cleanup; verify none are load-bearing.

## Testing

- **rpi4 (fixed, wifi+BT):** service installed; wlan0 present at boot → cascade
  fires; BT present → BLE enabled; commissioning API reachable. Behaviour
  unchanged from today.
- **tauri (fixed, no wifi):** service not installed; nothing enabled.
- **x86, no wifi adapter:** installed but nothing starts; no error spam.
- **x86, wifi adapter, no BT:** wpa_supplicant + commissioning start; probe adds
  `--disable-ble`; Unix API works; no BLE error.
- **x86, wifi + BT adapter:** full function including BLE.
- **x86, hot-plug wifi dongle after boot:** udev triggers the cascade; services
  come up.
- **adapter removal:** `BindsTo` tears down wpa_supplicant and, transitively,
  the commissioning service.

## Open items for the plan

- Split into two PRs (meta-omnect, omnect-os) with the meta-omnect change landing
  first, since the CI configs depend on it. (Resolved in the plan.)

Both other former open items are now resolved: `wpa_supplicant@.service` `Wants`
the service (continuous BLE advertising), and the runtime BLE decision uses an
ExecStart-override drop-in rather than `ExecStartPre` (see BT handling above).
