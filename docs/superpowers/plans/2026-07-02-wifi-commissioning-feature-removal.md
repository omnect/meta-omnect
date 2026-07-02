# Remove `wifi-commissioning` DISTRO_FEATURE — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `DISTRO_FEATURES` `wifi` the single gate for wifi commissioning, with universal runtime adapter-gating and runtime BLE decision, and remove the separate `wifi-commissioning` feature.

**Architecture:** Install gate flips to `wifi`. A udev rule + `BindsTo` on `wpa_supplicant@.service` becomes the single runtime start-gate; the commissioning service rides along via a forward `Wants=` from `wpa_supplicant` (option A). The BLE `--disable-ble` decision moves to runtime via a systemd drop-in that probes for a BT adapter at start. No change to the upstream `wifi-commissioning-service` binary.

**Tech Stack:** Yocto/BitBake (dunfell-era layout), systemd unit files + udev, KAS build configs, POSIX shell CI tests.

## Global Constraints

- **Two repos, two PRs.** meta-omnect changes (Tasks 1–5) land first; omnect-os changes (Tasks 6–8) depend on them.
- **Source repo of truth:** the recipe builds `github.com/omnect/wifi-commissioning-service` (BLE + Unix socket, self-degrading on missing BT). It is *not* the legacy `wifi-commissioning-gatt-service`.
- **No binary change** to `wifi-commissioning-service`.
- **Systemd `$` escaping:** inside unit-file `ExecStart`, a literal `$` for the executed shell is written as `$$`. `%I`/`%i` are systemd specifiers, expanded by systemd.
- **BT presence probe:** `ls /sys/class/bluetooth/hci* >/dev/null 2>&1` (sysfs only, no tools, world-readable — runs fine as the service user).
- **Commit sign-off (required on every commit):**
  `Signed-off-by: Jan Zachmann 50990105+JanZachmann@users.noreply.github.com`
- **Verification reality:** recipe/unit changes are verified by (a) content grep, (b) `bitbake -p` parse, (c) targeted recipe build + inspecting the packaged unit files under the recipe `WORKDIR`, and (d) a final image build + on-target CI (`ci/tests/base_test.sh`). Build steps require a set-up build environment (KAS / `oe-init-build-env` in `omnect-os/build`); where a step needs it, it says so.

### Deviation from the spec (recorded)

The spec proposed `ExecStartPre` + a generated env file for the runtime `--disable-ble` decision. That does not work: systemd reads `EnvironmentFile=` once at service start, *before* `ExecStartPre` runs, so a file written by `ExecStartPre` of the same unit is never re-read by `ExecStart`. This plan instead ships a systemd **drop-in** that overrides `ExecStart` with inline BT detection, still honoring an operator override via the existing `EnvironmentFile=-/etc/omnect/wifi-commissioning-service.env`. Same runtime outcome; correct ordering; no fragile sed escaping. Update the spec's "BT handling" section to match.

---

## File structure

**meta-omnect (PR 1)**
- `recipes-omnect/images/omnect-os-image.bb` — install gate `wifi-commissioning` → `wifi`.
- `recipes-connectivity/wpa-supplicant/wpa-supplicant/wpa_supplicant@.service` — adapter binding + forward Wants.
- `recipes-connectivity/wpa-supplicant/wpa-supplicant/80-wlan-wpa.rules` *(new)* — udev device-activation.
- `recipes-connectivity/wpa-supplicant/wpa-supplicant_%.bbappend` — ship udev rule; drop static enable symlink.
- `recipes-omnect/wifi-commissioning-service/wifi-commissioning-service.inc` — drop sanity check; drop static symlinks; drop build-time `--disable-ble`; keep BT-dep strip; ship ExecStart drop-in.
- `recipes-omnect/wifi-commissioning-service/files/10-omnect-runtime.conf` *(new)* — ExecStart override drop-in.
- `dynamic-layers/raspberrypi/recipes-connectivity/bluez5/bluez5_%.bbappend` — re-key guard to `wifi`.
- `kas/example/wifi-commissioning.yaml` — delete.

**omnect-os (PR 2)**
- `ci/machine/{rpi4,rpi4-omnect-lab,rpi3,polis4}.yaml` — remove the kas include line.
- `ci/tests/base_test.sh` — re-key + adapter-aware commissioning check.
- `doc/legal/1_howto_get_sources_and_licenses.md`, `doc/legal/2_howto_build_image.md` — drop `wifi-commissioning.yaml` references.
- Stale `wifi-commissioning-gatt` whitelist entries — remove if not load-bearing.

---

## Task 1: Flip the install gate and remove the opt-in feature

**Files:**
- Modify: `recipes-omnect/images/omnect-os-image.bb:69`
- Modify: `recipes-omnect/wifi-commissioning-service/wifi-commissioning-service.inc:10-15`
- Delete: `kas/example/wifi-commissioning.yaml`

**Interfaces:**
- Produces: `wifi-commissioning-service` is installed iff `DISTRO_FEATURES` contains `wifi`. The `wifi-commissioning` feature no longer exists anywhere in meta-omnect.

- [ ] **Step 1: Flip the image install gate**

In `recipes-omnect/images/omnect-os-image.bb`, replace the line:
```
    ${@bb.utils.contains('DISTRO_FEATURES', 'wifi-commissioning', ' wifi-commissioning-service', '', d)} \
```
with:
```
    ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', ' wifi-commissioning-service', '', d)} \
```

- [ ] **Step 2: Remove the now-obsolete sanity check**

In `recipes-omnect/wifi-commissioning-service/wifi-commissioning-service.inc`, delete the block (lines 10-15):
```
# wifi-commissioning without wifi makes no sense
python () {
    if bb.utils.contains('DISTRO_FEATURES', 'wifi-commissioning', True, False, d) and \
       not bb.utils.contains('DISTRO_FEATURES', 'wifi', True, False, d):
        bb.fatal("DISTRO_FEATURES contains 'wifi-commissioning' but not 'wifi'")
}
```

- [ ] **Step 3: Delete the opt-in KAS example**

Run:
```bash
git rm kas/example/wifi-commissioning.yaml
```

- [ ] **Step 4: Verify no `wifi-commissioning` DISTRO_FEATURE references remain**

Run:
```bash
grep -rn "wifi-commissioning" --include="*.bb" --include="*.bbappend" --include="*.inc" --include="*.conf" --include="*.yaml" . | grep -i "DISTRO_FEATURES\|contains.*wifi-commissioning'"
```
Expected: only the `bluez5_%.bbappend` guard remains (fixed in Task 4). No hits in the image recipe, the `.inc`, or `kas/`.

- [ ] **Step 5: Parse-check**

Run (from the build environment):
```bash
bitbake -p
```
Expected: parses with no error.

- [ ] **Step 6: Commit**

```bash
git add recipes-omnect/images/omnect-os-image.bb recipes-omnect/wifi-commissioning-service/wifi-commissioning-service.inc
git commit -s -m "feat(wifi): gate commissioning on DISTRO_FEATURES 'wifi'

Remove the separate 'wifi-commissioning' feature; 'wifi' is now the
single install gate. Delete the opt-in KAS example."
```
(`-s` adds the required Signed-off-by.)

---

## Task 2: Adapter-gate `wpa_supplicant` via udev + BindsTo (option A)

**Files:**
- Modify: `recipes-connectivity/wpa-supplicant/wpa-supplicant/wpa_supplicant@.service`
- Create: `recipes-connectivity/wpa-supplicant/wpa-supplicant/80-wlan-wpa.rules`
- Modify: `recipes-connectivity/wpa-supplicant/wpa-supplicant_%.bbappend`

**Interfaces:**
- Consumes: install gate from Task 1 (co-installs the commissioning service on wifi images).
- Produces: on `wlan*` appearance, `wpa_supplicant@<dev>.service` starts (bound to the device) and pulls `wifi-commissioning-service@<dev>.service` via `Wants=`. No static `multi-user.target.wants` symlink for wpa_supplicant.

- [ ] **Step 1: Rewrite the wpa_supplicant unit's `[Unit]` gating**

In `recipes-connectivity/wpa-supplicant/wpa-supplicant/wpa_supplicant@.service`, replace the current `[Unit]` block:
```
[Unit]
Description=WPA supplicant daemon
Requires=sys-subsystem-net-devices-%i.device
After=sys-subsystem-net-devices-%i.device
Before=network.target
Wants=network.target
# unfortunately this has no real benefit: https://github.com/systemd/systemd/issues/985
ConditionPathExists=/sys/class/net/%i

StartLimitBurst=10
StartLimitIntervalSec=120
```
with:
```
[Unit]
Description=WPA supplicant daemon
# Bind to the wlan device so the daemon starts when the adapter appears
# (via udev, incl. hot-plugged USB dongles) and stops when it is removed.
BindsTo=sys-subsystem-net-devices-%i.device
After=sys-subsystem-net-devices-%i.device
Before=network.target
Wants=network.target
# Single adapter gate for wifi commissioning (option A): pull the
# commissioning service in when wpa_supplicant starts for this device.
Wants=wifi-commissioning-service@%i.service

StartLimitBurst=10
StartLimitIntervalSec=120
```

- [ ] **Step 2: Remove the static-enable `[Install]` symlink line from the bbappend**

In `recipes-connectivity/wpa-supplicant/wpa-supplicant_%.bbappend`, delete these two lines from `do_install:append()`:
```
    install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants
    ln -rs ${D}${systemd_system_unitdir}/wpa_supplicant@.service ${D}${sysconfdir}/systemd/system/multi-user.target.wants/wpa_supplicant@wlan0.service
```

- [ ] **Step 3: Create the udev rule**

Create `recipes-connectivity/wpa-supplicant/wpa-supplicant/80-wlan-wpa.rules`:
```
# Start wpa_supplicant for each wlan interface as it appears.
# This is the single runtime gate for wifi (and, via wpa_supplicant's
# Wants=, wifi commissioning). Works on fixed hardware (device present at
# boot) and generic hardware incl. hot-plugged USB wifi dongles.
SUBSYSTEM=="net", KERNEL=="wlan*", ACTION=="add", TAG+="systemd", ENV{SYSTEMD_WANTS}+="wpa_supplicant@%k.service"
```

- [ ] **Step 4: Ship the udev rule from the bbappend**

In `recipes-connectivity/wpa-supplicant/wpa-supplicant_%.bbappend`, add `file://80-wlan-wpa.rules` to `SRC_URI` and install it. The `SRC_URI` becomes:
```
SRC_URI += "\
    file://wpa_supplicant.conf\
    file://wpa_supplicant@.service\
    file://80-wlan-wpa.rules\
    "
```
and add to `do_install:append()` (after the unit install, before `inherit`):
```
    install -d ${D}${nonarch_base_libdir}/udev/rules.d
    install -m 0644 ${WORKDIR}/80-wlan-wpa.rules ${D}${nonarch_base_libdir}/udev/rules.d/80-wlan-wpa.rules
```
Add the packaged file so QA does not complain:
```
FILES:${PN} += "${nonarch_base_libdir}/udev/rules.d/80-wlan-wpa.rules"
```

- [ ] **Step 5: Build the recipe and inspect the packaged files**

Run (build environment required):
```bash
bitbake wpa-supplicant
```
Then inspect the staged image (path pattern; the executor resolves the exact `WORKDIR`):
```bash
find tmp*/work -path "*wpa-supplicant*/image*" \( -name "wpa_supplicant@.service" -o -name "80-wlan-wpa.rules" \) 2>/dev/null
```
Verify in `wpa_supplicant@.service`: `BindsTo=sys-subsystem-net-devices-%i.device` present, `ConditionPathExists` gone, `Wants=wifi-commissioning-service@%i.service` present. Verify the rule file installed under `.../udev/rules.d/`. Verify there is **no** `multi-user.target.wants/wpa_supplicant@wlan0.service` symlink in the image.

- [ ] **Step 6: Commit**

```bash
git add recipes-connectivity/wpa-supplicant/
git commit -s -m "feat(wifi): adapter-gate wpa_supplicant via udev + BindsTo

Replace static enablement with a wlan* udev rule and BindsTo on the
net device, so wpa_supplicant starts only when an adapter is present
(incl. hot-plug) and stops when it is removed. Pull the commissioning
service in via Wants= (single gate, option A)."
```

---

## Task 3: Runtime BLE decision + drop static symlinks in the commissioning recipe

**Files:**
- Create: `recipes-omnect/wifi-commissioning-service/files/10-omnect-runtime.conf`
- Modify: `recipes-omnect/wifi-commissioning-service/wifi-commissioning-service.inc:24-48`
- Modify: `recipes-omnect/wifi-commissioning-service/wifi-commissioning-service_0.1.0.bb` (SRC_URI for the new file)

**Interfaces:**
- Consumes: the `Wants=` from Task 2 starts `wifi-commissioning-service@<dev>.service`.
- Produces: the commissioning service is no longer statically enabled; it is pulled by `wpa_supplicant`'s `Wants=` and its own `Requires=...@%i.socket`. `--disable-ble` is decided at runtime from BT-adapter presence, with operator override via `WIFI_COMMISSIONING_EXTRA_ARGS`.

- [ ] **Step 1: Create the ExecStart drop-in**

Create `recipes-omnect/wifi-commissioning-service/files/10-omnect-runtime.conf`:
```
[Service]
# Override upstream ExecStart to decide --disable-ble at runtime from real
# BT-adapter presence. Operator override: set WIFI_COMMISSIONING_EXTRA_ARGS
# in /etc/omnect/wifi-commissioning-service.env (already loaded by the unit).
# $$ escapes a literal $ for the bash the unit launches; %I is expanded by systemd.
ExecStart=
ExecStart=/bin/bash -c 'ARGS="$${WIFI_COMMISSIONING_EXTRA_ARGS-}"; if [ -z "$$ARGS" ] && ! ls /sys/class/bluetooth/hci* >/dev/null 2>&1; then ARGS="--disable-ble"; fi; exec /usr/bin/wifi-commissioning-service -i %I -s $$(/usr/bin/omnect_get_deviceid.sh) $$ARGS'
```

- [ ] **Step 2: Add the drop-in to `SRC_URI`**

In `recipes-omnect/wifi-commissioning-service/wifi-commissioning-service_0.1.0.bb`, append to `SRC_URI`:
```
SRC_URI += "file://10-omnect-runtime.conf"
```
(Place it near the top with the other `SRC_URI +=` lines. `FILESEXTRAPATHS` for `files/` is provided by the default recipe layout; if not present, add `FILESEXTRAPATHS:prepend := "${THISDIR}/files:"` to the `.inc`.)

- [ ] **Step 3: Rewrite `do_install:append()` in the `.inc`**

Replace the whole current `do_install:append()` (lines 24-48) with:
```
do_install:append() {
    # Install systemd template units
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/systemd/wifi-commissioning-service@.service ${D}${systemd_system_unitdir}/
    install -m 0644 ${S}/systemd/wifi-commissioning-service@.socket ${D}${systemd_system_unitdir}/

    # Runtime ExecStart override: decide --disable-ble from BT-adapter presence.
    install -d ${D}${systemd_system_unitdir}/wifi-commissioning-service@.service.d
    install -m 0644 ${WORKDIR}/10-omnect-runtime.conf \
        ${D}${systemd_system_unitdir}/wifi-commissioning-service@.service.d/10-omnect-runtime.conf

    # When bluetooth is absent from the build there is no bluetooth.service unit,
    # so strip the dependency (the runtime ExecStart already adds --disable-ble).
    if [ "${@bb.utils.contains('DISTRO_FEATURES', 'bluetooth', 'yes', 'no', d)}" = "no" ]; then
        sed -i '/^Requires=bluetooth.service$/d' \
            ${D}${systemd_system_unitdir}/wifi-commissioning-service@.service
        sed -i '/^After=bluetooth.service$/d' \
            ${D}${systemd_system_unitdir}/wifi-commissioning-service@.service
    fi

    # No static enablement: the service is pulled by wpa_supplicant's Wants=
    # and its own Requires=...@%i.socket, gated by the wlan udev rule.
}
```
Note what changed: removed the build-time `--disable-ble` `sed` on `ExecStart`; removed both `multi-user.target.wants` and `sockets.target.wants` symlink creation; added the drop-in install.

- [ ] **Step 4: Add the drop-in to `FILES`**

In the `.inc`, extend the existing `FILES:${PN}` block:
```
FILES:${PN} += "\
    ${systemd_system_unitdir}/wifi-commissioning-service@.service \
    ${systemd_system_unitdir}/wifi-commissioning-service@.socket \
    ${systemd_system_unitdir}/wifi-commissioning-service@.service.d/10-omnect-runtime.conf \
"
```

- [ ] **Step 5: Build the recipe and inspect**

Run (build environment required):
```bash
bitbake wifi-commissioning-service
```
Inspect the staged image:
```bash
find tmp*/work -path "*wifi-commissioning-service*/image*" \( -name "10-omnect-runtime.conf" -o -name "wifi-commissioning-service@.service" \) 2>/dev/null
find tmp*/work -path "*wifi-commissioning-service*/image*" -path "*target.wants*" 2>/dev/null
```
Verify: the drop-in exists under `wifi-commissioning-service@.service.d/`; the base `@.service` no longer has `--disable-ble` appended to `ExecStart`; there are **no** `*.target.wants` symlinks in the image.

- [ ] **Step 6: Commit**

```bash
git add recipes-omnect/wifi-commissioning-service/
git commit -s -m "feat(wifi): decide --disable-ble at runtime; drop static enablement

Ship a drop-in that overrides ExecStart to probe for a BT adapter at
start and add --disable-ble when none is present (operator override via
WIFI_COMMISSIONING_EXTRA_ARGS). Remove static target.wants symlinks; the
service is now pulled by wpa_supplicant and adapter-gated by udev."
```

---

## Task 4: Re-key the bluez5 restart workaround

**Files:**
- Modify: `dynamic-layers/raspberrypi/recipes-connectivity/bluez5/bluez5_%.bbappend:5`

**Interfaces:**
- Consumes: nothing new.
- Produces: the `bluetooth.service` `PartOf` patch now applies when `DISTRO_FEATURES` contains `wifi` (the new gate) instead of the removed `wifi-commissioning`.

- [ ] **Step 1: Re-key the guard**

Change line 5 from:
```
    if ${@bb.utils.contains('DISTRO_FEATURES', 'wifi-commissioning', 'true', 'false', d)}; then
```
to:
```
    if ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', 'true', 'false', d)}; then
```

- [ ] **Step 2: Verify**

Run:
```bash
grep -n "contains" dynamic-layers/raspberrypi/recipes-connectivity/bluez5/bluez5_%.bbappend
```
Expected: the guard now references `'wifi'`.

- [ ] **Step 3: Commit**

```bash
git add dynamic-layers/raspberrypi/recipes-connectivity/bluez5/bluez5_%.bbappend
git commit -s -m "fix(bluez5): re-key commissioning workaround guard to 'wifi'"
```

---

## Task 5: Integration build + inspection (meta-omnect)

**Files:** none (verification only).

**Interfaces:**
- Consumes: Tasks 1–4.
- Produces: confidence that images build and the units are wired correctly, before touching omnect-os.

- [ ] **Step 1: Build the x86 image (generic hardware)**

Run (build environment; genericx86-64 machine):
```bash
bitbake omnect-os-image
```
Expected: builds successfully.

- [ ] **Step 2: Confirm the install gate resolved**

Run:
```bash
bitbake-getvar -r omnect-os-image IMAGE_INSTALL | grep wifi-commissioning-service
```
Expected: `wifi-commissioning-service` present (genericx86-64 has `wifi` in MACHINE_FEATURES → DISTRO_FEATURES).

- [ ] **Step 3: Inspect the assembled rootfs unit wiring**

In the rootfs (`find tmp*/work -path "*omnect-os-image*/rootfs"`), verify:
```bash
# udev rule present
test -f <rootfs>/lib/udev/rules.d/80-wlan-wpa.rules && echo OK-udev
# wpa unit bound to device, wants commissioning
grep -e BindsTo -e "Wants=wifi-commissioning" <rootfs>/lib/systemd/system/wpa_supplicant@.service
# commissioning drop-in present
test -f <rootfs>/lib/systemd/system/wifi-commissioning-service@.service.d/10-omnect-runtime.conf && echo OK-dropin
# NO static enablement symlinks
find <rootfs>/etc/systemd/system -name "wpa_supplicant@wlan0.service" -o -name "wifi-commissioning-service@wlan0.*"
```
Expected: `OK-udev`, `OK-dropin`, `BindsTo`/`Wants` lines present, and the final `find` prints nothing.

- [ ] **Step 4: Build an ARM image to confirm the fixed-HW path**

Run (raspberrypi4-64 machine): `bitbake omnect-os-image`. Confirm `IMAGE_INSTALL` still contains `wifi-commissioning-service` (rpi4 has wifi), and that a `tauri`/no-wifi machine build does **not** (spot check with `bitbake-getvar` for that MACHINE).

- [ ] **Step 5: No commit** (verification task). If any check fails, fix in the owning task and re-run.

---

## Task 6: Remove the KAS include from omnect-os CI machine configs

**Files:**
- Modify: `ci/machine/rpi4.yaml:6`
- Modify: `ci/machine/rpi4-omnect-lab.yaml:5`
- Modify: `ci/machine/rpi3.yaml:6`
- Modify: `ci/machine/polis4.yaml:6`

**Interfaces:**
- Consumes: meta-omnect PR 1 merged (the example file no longer exists).
- Produces: CI builds no longer set the removed `wifi-commissioning` feature; they get commissioning via `wifi` automatically.

- [ ] **Step 1: Remove the include line from each file**

In each of the four files, delete the line:
```
  ${YOCTO_BUILD_DIR}/meta-omnect/kas/example/wifi-commissioning.yaml:\
```
Keep the surrounding `"\` … `"` block and the remaining machine yaml include intact (e.g. `rpi4.yaml` keeps `${YOCTO_BUILD_DIR}/meta-omnect/kas/machine/rpi/rpi4.yaml`).

- [ ] **Step 2: Verify no references remain**

Run:
```bash
grep -rn "wifi-commissioning.yaml" ci/
```
Expected: no output.

- [ ] **Step 3: Lint the YAML**

Run:
```bash
for f in ci/machine/rpi4.yaml ci/machine/rpi4-omnect-lab.yaml ci/machine/rpi3.yaml ci/machine/polis4.yaml; do python3 -c "import yaml,sys; yaml.safe_load(open('$f'))" && echo "OK $f"; done
```
Expected: `OK` for all four.

- [ ] **Step 4: Commit**

```bash
git add ci/machine/rpi4.yaml ci/machine/rpi4-omnect-lab.yaml ci/machine/rpi3.yaml ci/machine/polis4.yaml
git commit -s -m "ci: drop wifi-commissioning KAS include; wifi feature gates it now"
```

---

## Task 7: Make the CI commissioning test key on `wifi` and adapter presence

**Files:**
- Modify: `ci/tests/base_test.sh:297-308`

**Interfaces:**
- Consumes: the deployed image where commissioning is gated by `wifi` and started only when a wlan adapter exists.
- Produces: `test_distro_feature_wifi_commissioning` passes when: (a) no `wifi` feature → service absent; (b) `wifi` + adapter present (`TEST_USES_WIFI=1`) → service active + API reachable; (c) `wifi` + no adapter → service not active but not failed.

- [ ] **Step 1: Rewrite the function**

Replace the current function (lines 297-308):
```
test_distro_feature_wifi_commissioning()
{
    local distro_features="${1}"
    local deadline="${2}"

    if contains "${distro_features}" "wifi-commissioning"; then
        test_systemd_service "wifi-commissioning-service@wlan0" "${deadline}" "is-active"
        test_wifi_commissioning_service_api
    elif service_enabled "wifi-commissioning-service@wlan0.service"; then
        test_fail "\"wifi-commissioning-service\" is enabled but DISTRO_FEATURE \"wifi-commissioning\" is not set."
    fi
}
```
with:
```
test_distro_feature_wifi_commissioning()
{
    local distro_features="${1}"
    local deadline="${2}"

    if ! contains "${distro_features}" "wifi"; then
        # No wifi feature: the commissioning service must not be present/active.
        if test_systemd_service "wifi-commissioning-service@wlan0" "${deadline}" "is-active" 2>/dev/null; then
            test_fail "\"wifi-commissioning-service\" is active but DISTRO_FEATURE \"wifi\" is not set."
        fi
        return
    fi

    # wifi feature present: start is gated at runtime on a wlan adapter.
    if [ "${TEST_USES_WIFI}" = "1" ]; then
        test_systemd_service "wifi-commissioning-service@wlan0" "${deadline}" "is-active"
        test_wifi_commissioning_service_api
    else
        # No adapter on this runner: the service must not be in a failed state.
        local state
        state=$(systemctl is-failed "wifi-commissioning-service@wlan0.service" 2>/dev/null)
        if [ "${state}" = "failed" ]; then
            test_fail "\"wifi-commissioning-service@wlan0\" is in failed state without a wifi adapter."
        fi
    fi
}
```

- [ ] **Step 2: Shellcheck / syntax-check**

Run:
```bash
bash -n ci/tests/base_test.sh && echo "syntax OK"
```
Expected: `syntax OK`. (If `shellcheck` is available, run it and confirm no new errors on the edited function.)

- [ ] **Step 3: Confirm the call site still matches**

Run:
```bash
grep -n "test_distro_feature_wifi_commissioning" ci/tests/base_test.sh
```
Expected: still called from `test_distro_features` with `"${distro_features}" "${deadline}"` — the signature is unchanged.

- [ ] **Step 4: Commit**

```bash
git add ci/tests/base_test.sh
git commit -s -m "test(ci): key commissioning check on 'wifi' + adapter presence

The service is now gated by DISTRO_FEATURES 'wifi' and only started when
a wlan adapter exists. Expect active+API only when TEST_USES_WIFI=1;
otherwise require it is simply not in a failed state."
```

---

## Task 8: Docs and stale legacy-artifact cleanup (omnect-os)

**Files:**
- Modify: `doc/legal/1_howto_get_sources_and_licenses.md:29,57`
- Modify: `doc/legal/2_howto_build_image.md:37,70`
- Modify (conditional): `ci/tests/whitelists/**/syslog_err_whitelist.json`

**Interfaces:**
- Consumes: nothing.
- Produces: docs no longer reference the deleted KAS example; obsolete `wifi-commissioning-gatt` whitelist noise removed if unused.

- [ ] **Step 1: Remove doc references to the KAS example**

In both `doc/legal/1_howto_get_sources_and_licenses.md` and `doc/legal/2_howto_build_image.md`, remove the lines that reference `meta-omnect/kas/example/wifi-commissioning.yaml`. Check surrounding prose still reads correctly (renumber/join list items if needed).

- [ ] **Step 2: Verify**

Run:
```bash
grep -rn "wifi-commissioning.yaml" doc/
```
Expected: no output.

- [ ] **Step 3: Assess the stale gatt whitelist entries**

The whitelists contain:
```
{"SYSLOG_IDENTIFIER":"systemd","MESSAGE":"Failed to start wifi-commissioning-gatt: commissioning wifi via bt."}
```
This refers to the legacy `wifi-commissioning-gatt-service`, which meta-omnect no longer builds. Confirm the current image emits no such message (grep a fresh test run's journal, or reason from Task 5: the deployed unit is `wifi-commissioning-service@wlan0`, not `wifi-commissioning-gatt`). If confirmed obsolete, remove those entries from each affected whitelist:
```
ci/tests/whitelists/rpi4/dunfell/syslog_err_whitelist.json
ci/tests/whitelists/rpi4/kirkstone/syslog_err_whitelist.json
ci/tests/whitelists/rpi4-omnect-lab/kirkstone/syslog_err_whitelist.json
ci/tests/whitelists/tauril2/kirkstone/syslog_err_whitelist.json
ci/tests/whitelists/dehndetect/kirkstone/syslog_err_whitelist.json
```
Keep each file valid JSON. If unsure whether an entry is still needed, leave it and note it for review rather than guessing.

- [ ] **Step 4: Validate JSON for any whitelist touched**

Run (for each modified file):
```bash
python3 -c "import json,sys; json.load(open('<file>'))" && echo "JSON OK"
```
Expected: `JSON OK`.

- [ ] **Step 5: Commit**

```bash
git add doc/ ci/tests/whitelists/
git commit -s -m "docs/ci: drop references to removed wifi-commissioning.yaml and stale gatt whitelist"
```

---

## Final integration (both PRs merged)

- [ ] Build + flash a raspberrypi4-64 image; boot; run `ci/tests/base_test.sh`. Confirm `wpa_supplicant@wlan0` and `wifi-commissioning-service@wlan0` are active, BLE up (BT present), and the commissioning API responds.
- [ ] Build + boot a genericx86-64 image **without** a wifi adapter; confirm neither service is active and neither is `failed`, and no BLE error is logged.
- [ ] On x86 **with** a wifi-but-no-BT dongle: confirm both services active, `--disable-ble` applied (no BLE error), Unix API works.
- [ ] Hot-plug a USB wifi dongle on a running x86 box; confirm the udev rule brings the services up; remove it and confirm they stop.

---

## Self-review

**Spec coverage:**
- Install gate → `wifi`: Task 1. ✓
- Universal udev + `BindsTo` start gate on wpa_supplicant, option A `Wants`: Task 2. ✓
- Drop static symlinks (wpa + both commissioning): Tasks 2, 3. ✓
- Runtime `--disable-ble` (corrected mechanism): Task 3. ✓
- Keep build-time bluetooth-dep strip: Task 3. ✓
- bluez5 re-key: Task 4. ✓
- Delete KAS example: Task 1. ✓
- CI machine includes: Task 6. ✓
- `base_test.sh` re-key + adapter-aware: Task 7. ✓
- Docs + stale gatt artifacts: Task 8. ✓
- Test matrix from spec: Task 5 + Final integration. ✓

**Placeholder scan:** none — all edits show exact content; `<rootfs>`/`<file>`/`tmp*/work` are genuine path patterns the executor resolves in a live build tree, not TODOs.

**Type/name consistency:** unit/file names consistent across tasks — `wpa_supplicant@.service`, `wifi-commissioning-service@.service`/`@.socket`/`@.service.d/10-omnect-runtime.conf`, udev `80-wlan-wpa.rules`, env var `WIFI_COMMISSIONING_EXTRA_ARGS`. Function `test_distro_feature_wifi_commissioning` keeps its `(distro_features, deadline)` signature.
