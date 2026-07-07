# wifi commissioning driven by device_caps.json — design

Date: 2026-07-07
Repo: meta-omnect (leading component)
Supersedes: PR #664 (`feat(wifi): make DISTRO_FEATURES 'wifi' the single gate for commissioning`)
Branch plan: continue on `chore`; close #664; open a new PR.

## 1. Summary

Replace the current wifi-commissioning gating with `/etc/omnect/device_caps.json`
as the single source of truth for **both** build-time (install + BLE compile) and
runtime (start + BLE activation) decisions. Remove the udev hot-plug path — a
fixed `wlan0` is assumed, hot-plug is no longer a requirement.

`device_caps.json` values are per-machine and use `no | optional | yes`:

- Build-time: `wifi ∈ {optional, yes}` → install `wpa-supplicant` + `wifi-commissioning-service` (wcs).
- Build-time: wcs installed **and** `bluetooth ∈ {optional, yes}` → compile wcs with the `ble` cargo feature.
- Runtime: `wifi == "yes"` → start wpa_supplicant + wcs. Otherwise nothing starts.
- Runtime: `bluetooth == "yes"` → start wcs with `--enable-ble`. Otherwise BLE stays off.

`optional` means "shipped but off": the field can be edited from `optional` → `yes`
after image build but before first boot to activate the feature. Build treats
`optional` and `yes` identically; only runtime distinguishes them.

## 2. Motivation

Today there are three overlapping gates that can disagree:

- `conf/distro/include/omnect-os-distro.conf` derives `DISTRO_FEATURES` wifi/bluetooth
  from **MACHINE_FEATURES**.
- `recipes-core/base-files/base-files_%.bbappend` ships a **separate** per-machine
  `device_caps.json`.
- `recipes-core/systemd/systemd_%.bbappend` gates wlan network config on
  **MACHINE_FEATURES wifi** (a third gate).

Nothing keeps these consistent. `genericx86-64.json` already says `wifi:"optional"`
with no guarantee `MACHINE_FEATURES` agrees. Making `device_caps.json` authoritative
for wifi/bluetooth removes the divergence and enables one image whose wifi/BLE state
is selectable per device before first boot.

`3g` is intentionally **not** migrated: its consumers (ODS `modemmanager` +
`modem_info` cargo feature, image cellular packages, kernel LTE `SRC_URI`) read
`MACHINE_FEATURES` directly, so it stays MACHINE_FEATURES-driven.

## 3. Scope

In scope (meta-omnect only):
- Build-time derivation of `DISTRO_FEATURES` wifi/bluetooth from `device_caps.json`.
- wcs BLE compile as a cargo feature.
- Runtime oneshot orchestrator; removal of udev.
- systemd unit adjustments.
- Documentation.

Out of scope (documented as dependencies, not implemented here):
- wcs source, ODS source, omnect-os.

## 4. Build-time design (single source of truth)

### 4.1 New class `classes/omnect-device-caps.bbclass`

```python
def omnect_device_cap(d, key):
    import json, os
    path = os.path.join(d.getVar('LAYERDIR_omnect'), 'files',
                        'device_caps', '%s.json' % d.getVar('MACHINE'))
    bb.parse.mark_dependency(d, path)   # re-parse when the JSON changes
    try:
        with open(path) as f:
            return json.load(f).get(key, '')
    except (IOError, ValueError):
        return ''
```

- `LAYERDIR_omnect` (set in `conf/layer.conf`) and `${MACHINE}` are both available at
  distro-conf parse time — verified.
- `bb.parse.mark_dependency` registers the JSON as a parse dependency. Exact behavior
  at config scope must be confirmed during implementation; CI clean builds are
  unaffected regardless.
- Missing/invalid file → empty string → feature not set (fail-safe).

### 4.2 `conf/distro/include/omnect-os-distro.conf`

Add near the top of the feature derivation block:

```
INHERIT += "omnect-device-caps"
```

Replace the wifi and bluetooth lines (current lines 13–14) with device_caps-derived
values. `3g` (line 12) is left untouched.

```
# wifi/bluetooth capability comes from files/device_caps/${MACHINE}.json
# ("optional" and "yes" both enable at build time; only runtime distinguishes them)
DISTRO_FEATURES += "${@'wifi'      if omnect_device_cap(d, 'wifi')      != 'no' else ''}"
DISTRO_FEATURES += "${@'bluetooth' if omnect_device_cap(d, 'bluetooth') != 'no' else ''}"
```

The `bluetooth` feature is derived independently. The "wcs installed **and**
bluetooth" rule is satisfied naturally because the `ble` cargo feature lives in the
wcs recipe, which is only built when `wifi` is installed.

### 4.3 `recipes-core/systemd/systemd_%.bbappend`

Switch the wlan network-config gate from `MACHINE_FEATURES wifi` to
`DISTRO_FEATURES wifi` so all wifi gating shares one source:

```
if ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', 'true', 'false', d)}; then
    install -m 0644 ${WORKDIR}/80-wlan.network ${D}${systemd_unitdir}/network
    install -m 0644 ${WORKDIR}/80-wlan0.link   ${D}${systemd_unitdir}/network
fi
```

### 4.4 wcs recipe — BLE as a cargo feature

`recipes-omnect/wifi-commissioning-service/wifi-commissioning-service.inc`:

- Change compile flags to add the `ble` feature when bluetooth is present:
  ```
  CARGO_BUILD_FLAGS += "--locked --features systemd"
  CARGO_BUILD_FLAGS += "${@bb.utils.contains('DISTRO_FEATURES', 'bluetooth', ' --features ble', '', d)}"
  ```
- Keep the bluez runtime dependency gated on `DISTRO_FEATURES bluetooth` (unchanged).
- **Remove** the `do_install:append` block that seds bluetooth ordering out and forces
  `--disable-ble` into `ExecStart`. Runtime BLE is now driven by the oneshot via an
  EnvironmentFile (§5), and BLE defaults off in wcs.

Dependency (out of scope): the wcs source must expose a `ble` cargo feature and
default BLE **off**, accepting `--enable-ble` to turn it on.

### 4.5 Install gate (unchanged)

`recipes-omnect/images/omnect-os-image.bb:69` keeps
`bb.utils.contains('DISTRO_FEATURES', 'wifi', ' wifi-commissioning-service', '', d)`.
It now transitively reflects `device_caps.json`.

## 5. Runtime design (oneshot orchestrator, no udev)

### 5.1 Remove udev hot-plug path

`recipes-connectivity/wpa-supplicant/wpa-supplicant_%.bbappend`:
- Delete `file://80-wlan-wpa.rules` from `SRC_URI`, its install line, and the
  `FILES:${PN}` entry.
- Delete the file `recipes-connectivity/wpa-supplicant/wpa-supplicant/80-wlan-wpa.rules`.

### 5.2 New oneshot orchestrator

New recipe (e.g. `recipes-omnect/omnect-wifi-commissioning/omnect-wifi-commissioning.bb`)
installed only under `DISTRO_FEATURES wifi`. Ships two files:

`omnect-wifi-commissioning.service`
```
[Unit]
Description=Configure and start wifi commissioning from device capabilities
ConditionPathExists=/etc/omnect/device_caps.json
After=local-fs.target
Before=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/omnect-wifi-commissioning-start

[Install]
WantedBy=multi-user.target
```

`/usr/bin/omnect-wifi-commissioning-start` (dependency-free shell; flat JSON authored
in-repo, no jq):
```sh
#!/bin/sh
set -eu

CAPS=/etc/omnect/device_caps.json
ENV_FILE=/run/omnect-wifi-commissioning.env
IFACE=wlan0

# read a flat "key": "value" pair from the caps file
cap() {
    sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" "$CAPS"
}

[ "$(cap wifi)" = "yes" ] || exit 0   # wifi not enabled -> nothing starts

if [ "$(cap bluetooth)" = "yes" ]; then
    printf 'WCS_BLE_ARGS=--enable-ble\n' > "$ENV_FILE"
else
    printf 'WCS_BLE_ARGS=\n' > "$ENV_FILE"
fi

systemctl start "wpa_supplicant@${IFACE}.service"
```

Notes:
- No hot-plug: `wlan0` is assumed. Machines whose `device_caps` says `wifi:"yes"`
  must have the wifi driver/firmware from their BSP `MACHINE_FEATURES`; device_caps
  must reflect real hardware support.
- `wifi != "yes"` exits 0 cleanly (oneshot succeeds, nothing else starts).

### 5.3 `wpa_supplicant@.service`

`recipes-connectivity/wpa-supplicant/wpa-supplicant/wpa_supplicant@.service`:
- Drop `BindsTo=sys-subsystem-net-devices-%i.device` (hot-unplug behavior no longer
  required). Keep `After=sys-subsystem-net-devices-%i.device` for ordering.
- Keep `Wants=wifi-commissioning-service@%i.service` so starting wpa pulls wcs.
- Remove the comment referencing the udev rule.

### 5.4 `wifi-commissioning-service@.service`

- Add `EnvironmentFile=-/run/omnect-wifi-commissioning.env`.
- Reference the BLE arg in `ExecStart` (e.g. `... $WCS_BLE_ARGS`).
- The forced `--disable-ble` sed from the recipe is gone (§4.4); BLE defaults off in
  the binary and is turned on only via `--enable-ble` from the env file.
- Bluetooth ordering (`Requires=`/`After=bluetooth.service`) is meaningful only on
  ble-compiled builds. Keep it in the shipped unit; on non-bluetooth builds
  `bluetooth.service` is absent and the ordering is inert. (Confirm inert vs. blocking
  during implementation; if it blocks, gate it out in the recipe under
  `DISTRO_FEATURES bluetooth`.)

### 5.5 bluez `PartOf` bbappend

`dynamic-layers/raspberrypi/recipes-connectivity/bluez5/bluez5_%.bbappend` — unchanged
(already gated on `DISTRO_FEATURES wifi`, still fed by device_caps).

## 6. BLE decision matrix

| `device_caps.bluetooth` | build: `ble` compiled? | runtime wcs arg | BLE state |
|---|---|---|---|
| `no`       | no  | (none)        | off (no BLE code) |
| `optional` | yes | (none)        | off (default) |
| `yes`      | yes | `--enable-ble`| on |

Runtime BLE active ⟺ `bluetooth == "yes"`. Because wcs defaults BLE off and only
turns on with an explicit flag, editing `bluetooth` down to `optional`/`no` before
first boot cannot accidentally enable BLE.

## 7. Documented dependencies (out of scope)

- **wcs source:** expose a `ble` cargo feature; default BLE off; add `--enable-ble`.
- **ODS:** no change. Its `wifi_commissioning` feature is observe-only — it queries the
  running wcs service-info API and reports `running`/`ble_enabled`/`interface` to the
  twin. Reporting keeps working regardless of how start/config is decided.
- **omnect-os:** none (the kas `wifi-commissioning` example was removed in #664).

## 8. Documentation changes

- `doc/wifi_commissioning.md` — rewrite around the device_caps model: build vs runtime
  semantics, `no|optional|yes`, editing pre-boot, no udev/hot-plug, `wlan0` assumption,
  BLE matrix.
- `README.md`, `doc/PHYTEC.md`, `doc/RASPBERRY-PI.md`, `doc/WELOTEC.md` — update the wifi
  feature mentions to reference device_caps instead of the removed `wifi-commissioning`
  DISTRO feature / kas example.

## 9. Testing

- `ci/tests/base_test.sh` — verify wifi-service assertions still hold under the oneshot
  start path (no udev). A `wifi:"yes"` device should show wpa_supplicant + wcs active; a
  `wifi:"optional"` (unedited) device should show them installed but inactive.
- `ci/tests/whitelists/**/*.json` — with the udev rule gone, hot-plug wpa log lines
  disappear. Add whitelist entries only if the new oneshot/start path emits expected
  noise (POSIX ERE).
- Build verification: clean build for a `wifi:"yes"` machine (rpi4-64), a
  `wifi:"optional"` machine (genericx86-64), and a `wifi:"no"` machine
  (phygate-tauri-l-imx8mm-2) to confirm install/compile gating.

## 10. Logistics (not design)

- Continue on the `chore` branch. Close #664 first (one open PR per branch→base), then
  open the new PR targeting the omnect org.
- wcs recipe SRCREV points to `janzachmann/wifi-commissioning-service` and the ODS
  recipe to `JanZachmann/omnect-device-service` (personal forks). CLAUDE.md requires
  omnect-org sources before merge — repoint or confirm intentional.

## 11. Open implementation risks to validate

1. `bb.parse.mark_dependency` at config-parse scope — confirm it registers the JSON so
   edits re-trigger parse; otherwise document a `bitbake` reparse step.
2. `Requires=/After=bluetooth.service` on non-bluetooth builds — confirm inert; gate out
   in the recipe if it blocks startup.
3. `wpa_supplicant@wlan0` start when the `.device` unit exists at boot for onboard
   adapters — confirm ordering/`After` does not deadlock without udev.
