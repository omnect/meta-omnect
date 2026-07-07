# wifi commissioning driven by device_caps.json — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `/etc/omnect/device_caps.json` the single source of truth for wifi/bluetooth gating at build time (DISTRO_FEATURES derivation, BLE cargo feature) and runtime (oneshot orchestrator + `--enable-ble`), and remove the udev hot-plug path.

**Architecture:** A new globally-inherited bbclass reads the per-machine `device_caps.json` at parse time; `omnect-os-distro.conf` derives `DISTRO_FEATURES` wifi/bluetooth from it. A new oneshot systemd service reads the installed `device_caps.json` at boot and starts/configures `wpa_supplicant@wlan0` (which pulls `wifi-commissioning-service@wlan0`). BLE is a compile-time cargo feature; runtime activation is a `--enable-ble` flag delivered via a `/run` EnvironmentFile.

**Tech Stack:** Yocto/BitBake (`.bb`/`.bbappend`/`.bbclass`), systemd unit files, POSIX shell, JSON.

**Spec:** `docs/superpowers/specs/2026-07-07-wifi-commissioning-device-caps-design.md`

## Global Constraints

- **Commits:** Conventional Commits `<type>(<scope>): <subject>`. Every commit MUST end with the trailer `Signed-off-by: Jan Zachmann <50990105+JanZachmann@users.noreply.github.com>`. Never add AI/Co-Authored-By trailers.
- **Integration layer only:** No BitBake *source* recipes are added; this layer wires components. (The oneshot recipe ships local integration files, which is allowed — it is not a third-party source recipe.)
- **device_caps values:** each capability is `"no" | "optional" | "yes"`. Build treats `optional` and `yes` identically (install/compile); only runtime distinguishes (`yes` = active).
- **3g stays on MACHINE_FEATURES** — do not migrate it; it has direct `MACHINE_FEATURES` consumers.
- **bluetooth derivation is gated on wifi:** `DISTRO_FEATURES bluetooth` only when `wifi != "no" AND bluetooth != "no"`.
- **Immutable rootfs:** runtime-written files go to `/run` (tmpfs), never `/etc` or rootfs.
- **Interface:** `wlan0` is assumed; no hot-plug.
- **BUILD PREREQUISITE (blocks compile/build/smoke, NOT the recipe edits):** the wcs source must expose a `ble` cargo feature (BLE default *off*) and an `--enable-ble` flag, and the wcs recipe `SRCREV` must be bumped to that commit. Until then, verify recipe/config logic with `bitbake -e` (parse-time expansion, no compile). Full `bitbake <target>` compiles and smoke tests run only after the SRCREV bump. Tasks 1, 2, 4, 5, 6 do not depend on this prerequisite; Task 3 and Task 7 do.

**Where to run bitbake:** from the build repo root (parent of `meta-omnect`), enter the configured build shell for the target MACHINE, e.g. `INTERACTIVE=1 ./dobi.sh <job>` (run `./dobi.sh` with no args to list jobs). Machines used for verification and their `device_caps.json`:
- `raspberrypi4-64` — `wifi:"yes"`, `bluetooth:"yes"`
- `genericx86-64` — `wifi:"optional"`, `bluetooth:"optional"`
- `phygate-tauri-l-imx8mm-2` — `wifi:"no"`, `bluetooth:"no"`

---

### Task 1: device_caps bbclass + DISTRO_FEATURES derivation

**Files:**
- Create: `classes/omnect-device-caps.bbclass`
- Modify: `conf/distro/include/omnect-os-distro.conf:11-14`

**Interfaces:**
- Produces: global function `omnect_device_cap(d, key) -> str` (returns the capability string, or `''` if the file/key is missing).
- Produces: `DISTRO_FEATURES` now contains `wifi` when `device_caps.wifi != "no"`, and `bluetooth` when `wifi != "no" AND bluetooth != "no"`. `3g` line is unchanged.

- [ ] **Step 1: Capture baseline DISTRO_FEATURES (before any change)**

For each of the three machines, in that machine's build shell:
```bash
bitbake -e omnect-os-image | grep '^DISTRO_FEATURES=' > /tmp/distro-features-<machine>-before.txt
```
Keep these files; Task 7 diffs against them.
Expected today: rpi4 and genericx86 include `wifi`/`bluetooth` only if their `MACHINE_FEATURES` do; tauri includes neither.

- [ ] **Step 2: Create the bbclass**

Create `classes/omnect-device-caps.bbclass`:
```python
# Reads per-machine capabilities from files/device_caps/${MACHINE}.json so that
# DISTRO_FEATURES (and any recipe) can gate on the same file used at runtime.
def omnect_device_cap(d, key):
    import json, os
    path = os.path.join(d.getVar('LAYERDIR_omnect'), 'files',
                        'device_caps', '%s.json' % d.getVar('MACHINE'))
    # re-trigger parse when the JSON changes
    bb.parse.mark_dependency(d, path)
    try:
        with open(path) as f:
            return json.load(f).get(key, '')
    except (IOError, ValueError):
        return ''
```

- [ ] **Step 3: Wire it into the distro config**

In `conf/distro/include/omnect-os-distro.conf`, replace lines 11-14:
```
#DISTRO_FEATURES depending on MACHINE_FEATURES:
DISTRO_FEATURES += "${@bb.utils.contains('MACHINE_FEATURES', '3g', '3g', '', d)}"
DISTRO_FEATURES += "${@bb.utils.contains('MACHINE_FEATURES', 'bluetooth', 'bluetooth', '', d)}"
DISTRO_FEATURES += "${@bb.utils.contains('MACHINE_FEATURES', 'wifi', 'wifi', '', d)}"
```
with:
```
INHERIT += "omnect-device-caps"

# 3g stays MACHINE_FEATURES-driven (direct MACHINE_FEATURES consumers exist).
DISTRO_FEATURES += "${@bb.utils.contains('MACHINE_FEATURES', '3g', '3g', '', d)}"

# wifi/bluetooth capability comes from files/device_caps/${MACHINE}.json.
# "optional" and "yes" both enable at build time; only runtime distinguishes them.
# bluetooth is gated on wifi: it is only meaningful when wcs (and thus BLE) is built.
DISTRO_FEATURES += "${@'wifi' if omnect_device_cap(d, 'wifi') != 'no' else ''}"
DISTRO_FEATURES += "${@'bluetooth' if (omnect_device_cap(d, 'wifi') != 'no' and omnect_device_cap(d, 'bluetooth') != 'no') else ''}"
```

- [ ] **Step 4: Verify derivation for all three machines**

In each machine's build shell:
```bash
bitbake -e omnect-os-image | grep '^DISTRO_FEATURES='
```
Expected:
- `raspberrypi4-64`: contains `wifi` and `bluetooth`.
- `genericx86-64`: contains `wifi` and `bluetooth` (both `optional`, wifi != "no").
- `phygate-tauri-l-imx8mm-2`: contains neither `wifi` nor `bluetooth`.

Also confirm no parse error/warning about `omnect_device_cap` or `LAYERDIR_omnect`.

- [ ] **Step 5: Commit**

```bash
git add classes/omnect-device-caps.bbclass conf/distro/include/omnect-os-distro.conf
git commit -m "feat(wifi): derive DISTRO_FEATURES wifi/bluetooth from device_caps.json

Signed-off-by: Jan Zachmann <50990105+JanZachmann@users.noreply.github.com>"
```

---

### Task 2: switch systemd wlan network gate to DISTRO_FEATURES

**Files:**
- Modify: `recipes-core/systemd/systemd_%.bbappend:23`

**Interfaces:**
- Consumes: `DISTRO_FEATURES wifi` from Task 1.

- [ ] **Step 1: Change the gate**

In `recipes-core/systemd/systemd_%.bbappend`, change line 23 from:
```
    if ${@bb.utils.contains('MACHINE_FEATURES', 'wifi', 'true', 'false', d)}; then
```
to:
```
    if ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', 'true', 'false', d)}; then
```
(Leave the two `install` lines for `80-wlan.network` and `80-wlan0.link` unchanged.)

- [ ] **Step 2: Verify the wlan files follow the wifi feature**

In the `raspberrypi4-64` shell (wifi):
```bash
bitbake -c install systemd
find $(bitbake -e systemd | sed -n 's/^D="\(.*\)"$/\1/p')/lib/systemd/network -name '80-wlan*' 2>/dev/null
```
Expected: `80-wlan.network` and `80-wlan0.link` present.

In the `phygate-tauri-l-imx8mm-2` shell (no wifi):
```bash
bitbake -c install systemd
find $(bitbake -e systemd | sed -n 's/^D="\(.*\)"$/\1/p')/lib/systemd/network -name '80-wlan*' 2>/dev/null
```
Expected: no output (files absent).

- [ ] **Step 3: Commit**

```bash
git add recipes-core/systemd/systemd_%.bbappend
git commit -m "refactor(wifi): gate wlan network config on DISTRO_FEATURES wifi

Signed-off-by: Jan Zachmann <50990105+JanZachmann@users.noreply.github.com>"
```

---

### Task 3: wcs recipe — BLE cargo feature + runtime BLE arg wiring

**Files:**
- Modify: `recipes-omnect/wifi-commissioning-service/wifi-commissioning-service.inc`

**Interfaces:**
- Consumes: `DISTRO_FEATURES bluetooth` from Task 1.
- Produces: the installed `wifi-commissioning-service@.service` sources `/run/omnect-wifi-commissioning.env` and appends `$$WCS_BLE_ARGS` to its `ExecStart` (the env var is populated by Task 4's oneshot).

> **PREREQUISITE:** full `bitbake wifi-commissioning-service` requires the wcs source `ble` feature + `--enable-ble` and a bumped `SRCREV` (see Global Constraints). This task's verification uses `bitbake -e` (parse-time, no compile) and installed-unit inspection via `-c install`, which do NOT require the compile to succeed.

- [ ] **Step 1: Add the `ble` cargo feature under bluetooth**

In `wifi-commissioning-service.inc`, immediately after the existing line:
```
CARGO_BUILD_FLAGS += "--locked --features systemd"
```
add:
```
# BLE is compiled in when the platform can use bluetooth (device_caps-derived).
CARGO_BUILD_FLAGS += "${@bb.utils.contains('DISTRO_FEATURES', 'bluetooth', ' --features ble', '', d)}"
```

- [ ] **Step 2: Replace the `do_install:append` BLE handling**

Replace the existing `do_install:append()` block:
```
do_install:append() {
    # Install systemd template units
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/systemd/wifi-commissioning-service@.service ${D}${systemd_system_unitdir}/
    install -m 0644 ${S}/systemd/wifi-commissioning-service@.socket ${D}${systemd_system_unitdir}/

    # Without the 'bluetooth' feature there is no bluez/bluetooth.service and BLE
    # can never work: drop the bluetooth ordering and force --disable-ble.
    if [ "${@bb.utils.contains('DISTRO_FEATURES', 'bluetooth', 'yes', 'no', d)}" = "no" ]; then
        sed -i '/^Requires=bluetooth.service$/d;/^After=bluetooth.service$/d' \
            ${D}${systemd_system_unitdir}/wifi-commissioning-service@.service
        sed -i "/^ExecStart/s|'$| --disable-ble'|" \
            ${D}${systemd_system_unitdir}/wifi-commissioning-service@.service
    fi

    # No static enablement: the service is pulled by wpa_supplicant's Wants=
    # and its own Requires=...@%i.socket, gated by the wlan udev rule.
}
```
with:
```
do_install:append() {
    # Install systemd template units
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/systemd/wifi-commissioning-service@.service ${D}${systemd_system_unitdir}/
    install -m 0644 ${S}/systemd/wifi-commissioning-service@.socket ${D}${systemd_system_unitdir}/

    # Runtime BLE decision comes from device_caps.json via omnect-wifi-commissioning-start,
    # which writes WCS_BLE_ARGS (--enable-ble or empty) to /run. Source that file and
    # expand the shell var inside the existing bash -c invocation. No braces so BitBake
    # does not try to expand it; $$ becomes a literal $ for systemd -> bash sees $WCS_BLE_ARGS.
    sed -i \
        -e '\#^EnvironmentFile=-/etc/omnect/wifi-commissioning-service.env$#a EnvironmentFile=-/run/omnect-wifi-commissioning.env' \
        -e "/^ExecStart/s|'$| \$\$WCS_BLE_ARGS'|" \
        ${D}${systemd_system_unitdir}/wifi-commissioning-service@.service

    # Without the 'bluetooth' feature there is no bluez/bluetooth.service: drop the ordering.
    # (BLE is off by default in the binary, so no runtime flag is needed here.)
    if [ "${@bb.utils.contains('DISTRO_FEATURES', 'bluetooth', 'yes', 'no', d)}" = "no" ]; then
        sed -i '/^Requires=bluetooth.service$/d;/^After=bluetooth.service$/d' \
            ${D}${systemd_system_unitdir}/wifi-commissioning-service@.service
    fi

    # No static enablement: the service is pulled by wpa_supplicant's Wants= and its own
    # Requires=...@%i.socket; startup is gated by omnect-wifi-commissioning.service.
}
```

- [ ] **Step 3: Verify cargo feature expansion (parse-time, no compile)**

In the `raspberrypi4-64` shell:
```bash
bitbake -e wifi-commissioning-service | grep '^CARGO_BUILD_FLAGS='
```
Expected: contains both `--features systemd` and `--features ble`.

- [ ] **Step 4: Verify unit patching via install task**

In the `raspberrypi4-64` shell (bluetooth present):
```bash
bitbake -c install wifi-commissioning-service
U=$(bitbake -e wifi-commissioning-service | sed -n 's/^D="\(.*\)"$/\1/p')/lib/systemd/system/wifi-commissioning-service@.service
grep -F 'EnvironmentFile=-/run/omnect-wifi-commissioning.env' "$U"
grep -F '$$WCS_BLE_ARGS' "$U"
grep -c '^Requires=bluetooth.service$' "$U"   # expect 1 (kept)
```
Expected: both greps match; the bluetooth `Requires=` count is `1`.

> If `bitbake -c install` fails because the compile step (`do_compile`) has not run and the prerequisite is not yet met, this inspection is deferred to Task 7. Note the deferral in the task checklist rather than skipping it silently.

- [ ] **Step 5: Commit**

```bash
git add recipes-omnect/wifi-commissioning-service/wifi-commissioning-service.inc
git commit -m "feat(wifi): compile BLE via cargo feature and wire runtime --enable-ble

Signed-off-by: Jan Zachmann <50990105+JanZachmann@users.noreply.github.com>"
```

---

### Task 4: oneshot orchestrator (recipe + service + script) and image install

**Files:**
- Create: `recipes-omnect/omnect-wifi-commissioning/omnect-wifi-commissioning.bb`
- Create: `recipes-omnect/omnect-wifi-commissioning/omnect-wifi-commissioning/omnect-wifi-commissioning.service`
- Create: `recipes-omnect/omnect-wifi-commissioning/omnect-wifi-commissioning/omnect-wifi-commissioning-start`
- Create (test): `recipes-omnect/omnect-wifi-commissioning/omnect-wifi-commissioning/test_caps_parse.sh`
- Modify: `recipes-omnect/images/omnect-os-image.bb:69`

**Interfaces:**
- Consumes: `/etc/omnect/device_caps.json` (installed by `base-files`); `wpa_supplicant@wlan0.service` (from Task 5 / wpa recipe).
- Produces: `/usr/bin/omnect-wifi-commissioning-start`, `omnect-wifi-commissioning.service` (oneshot); writes `/run/omnect-wifi-commissioning.env` with `WCS_BLE_ARGS`.

- [ ] **Step 1: Write the failing parser test**

The only genuinely unit-testable logic is the flat-JSON `cap()` reader. Test it against the real sample files. Create `recipes-omnect/omnect-wifi-commissioning/omnect-wifi-commissioning/test_caps_parse.sh`:
```sh
#!/bin/sh
# Unit test for the cap() parser in omnect-wifi-commissioning-start.
# Runs the script's parser against the checked-in device_caps samples.
set -eu

HERE=$(dirname "$0")
SCRIPT="$HERE/omnect-wifi-commissioning-start"
CAPS_DIR="$HERE/../../../files/device_caps"

# Extract just the cap() function from the start script and exercise it.
run_cap() {
    CAPS="$1" sh -c '
        . '"$SCRIPT"'.capfn
        cap "'"$2"'"
    '
}

fail=0
check() { # file key expected
    got=$(run_cap "$CAPS_DIR/$1" "$2")
    if [ "$got" != "$3" ]; then
        echo "FAIL: $1 $2 => '$got' (expected '$3')"; fail=1
    else
        echo "ok: $1 $2 => '$got'"
    fi
}

check raspberrypi4-64.json wifi yes
check raspberrypi4-64.json bluetooth yes
check genericx86-64.json wifi optional
check genericx86-64.json bluetooth optional
check phygate-tauri-l-imx8mm-2.json wifi no
check phygate-tauri-l-imx8mm-2.json bluetooth no

exit $fail
```

To keep the parser testable in isolation, the start script sources a tiny companion file holding `cap()`. Create the companion path referenced above: `omnect-wifi-commissioning-start.capfn` (created in Step 3).

- [ ] **Step 2: Run the test — expect failure**

```bash
sh recipes-omnect/omnect-wifi-commissioning/omnect-wifi-commissioning/test_caps_parse.sh
```
Expected: fails — the script/companion do not exist yet (`No such file`).

- [ ] **Step 3: Write the start script and its cap() companion**

Create `recipes-omnect/omnect-wifi-commissioning/omnect-wifi-commissioning/omnect-wifi-commissioning-start.capfn`:
```sh
# cap KEY -> value of "KEY": "value" from the flat device_caps JSON in $CAPS.
# Sourced by omnect-wifi-commissioning-start and by test_caps_parse.sh.
cap() {
    sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" "$CAPS"
}
```

Create `recipes-omnect/omnect-wifi-commissioning/omnect-wifi-commissioning/omnect-wifi-commissioning-start`:
```sh
#!/bin/sh
# Start and configure wifi commissioning from /etc/omnect/device_caps.json.
# Runs once at boot (oneshot). No hot-plug: wlan0 is assumed.
set -eu

CAPS=/etc/omnect/device_caps.json
ENV_FILE=/run/omnect-wifi-commissioning.env
IFACE=wlan0

# shellcheck source=omnect-wifi-commissioning-start.capfn
. "$(dirname "$0")/omnect-wifi-commissioning-start.capfn"

[ "$(cap wifi)" = "yes" ] || exit 0   # wifi not enabled -> start nothing

if [ "$(cap bluetooth)" = "yes" ]; then
    printf 'WCS_BLE_ARGS=--enable-ble\n' > "$ENV_FILE"
else
    printf 'WCS_BLE_ARGS=\n' > "$ENV_FILE"
fi

# --no-block: we are inside the boot transaction; do not wait on the started jobs.
# wpa_supplicant@%i pulls wifi-commissioning-service@%i via its Wants=.
systemctl start --no-block "wpa_supplicant@${IFACE}.service"
```

Note for the recipe (Step 5): the `. "$(dirname "$0")/..."` source works only if the `.capfn` sits next to the installed binary. The recipe installs both into `${bindir}`. (The test sources it directly from the source tree.)

- [ ] **Step 4: Run the test — expect pass**

```bash
sh recipes-omnect/omnect-wifi-commissioning/omnect-wifi-commissioning/test_caps_parse.sh
```
Expected: all six `ok:` lines, exit 0.

- [ ] **Step 5: Write the oneshot service unit**

Create `recipes-omnect/omnect-wifi-commissioning/omnect-wifi-commissioning/omnect-wifi-commissioning.service`:
```
[Unit]
Description=Configure and start wifi commissioning from device capabilities
ConditionPathExists=/etc/omnect/device_caps.json
After=local-fs.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/omnect-wifi-commissioning-start

[Install]
WantedBy=multi-user.target
```

- [ ] **Step 6: Write the recipe**

Create `recipes-omnect/omnect-wifi-commissioning/omnect-wifi-commissioning.bb` (mirrors `omnect-first-boot.bb`):
```
DESCRIPTION = "Oneshot that starts/configures wifi commissioning from /etc/omnect/device_caps.json"

LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
"

inherit systemd

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://omnect-wifi-commissioning.service \
    file://omnect-wifi-commissioning-start \
    file://omnect-wifi-commissioning-start.capfn \
"

RDEPENDS:${PN} += "wpa-supplicant"

do_install() {
    install -m 0644 -D ${WORKDIR}/omnect-wifi-commissioning.service ${D}${systemd_system_unitdir}/omnect-wifi-commissioning.service
    install -m 0755 -D ${WORKDIR}/omnect-wifi-commissioning-start ${D}${bindir}/omnect-wifi-commissioning-start
    install -m 0644 -D ${WORKDIR}/omnect-wifi-commissioning-start.capfn ${D}${bindir}/omnect-wifi-commissioning-start.capfn
}

SYSTEMD_SERVICE:${PN} = "omnect-wifi-commissioning.service"

FILES:${PN} = "\
    ${bindir}/omnect-wifi-commissioning-start \
    ${bindir}/omnect-wifi-commissioning-start.capfn \
    ${systemd_system_unitdir}/omnect-wifi-commissioning.service \
"
```

- [ ] **Step 7: Add the oneshot to the image install (gated by wifi)**

In `recipes-omnect/images/omnect-os-image.bb`, change line 69 from:
```
    ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', ' wifi-commissioning-service', '', d)} \
```
to:
```
    ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', ' wifi-commissioning-service omnect-wifi-commissioning', '', d)} \
```

- [ ] **Step 8: Verify recipe parses and packages the files**

In the `raspberrypi4-64` shell:
```bash
bitbake -e omnect-wifi-commissioning >/dev/null && echo "parse ok"
bitbake -c install omnect-wifi-commissioning
D=$(bitbake -e omnect-wifi-commissioning | sed -n 's/^D="\(.*\)"$/\1/p')
ls "$D/usr/bin/omnect-wifi-commissioning-start" "$D/usr/bin/omnect-wifi-commissioning-start.capfn"
ls "$D/lib/systemd/system/omnect-wifi-commissioning.service"
bitbake -e omnect-os-image | grep '^IMAGE_INSTALL=' | grep -o 'omnect-wifi-commissioning'
```
Expected: `parse ok`; all three `ls` targets exist; `omnect-wifi-commissioning` appears in `IMAGE_INSTALL`.

In the `phygate-tauri-l-imx8mm-2` shell:
```bash
bitbake -e omnect-os-image | grep '^IMAGE_INSTALL=' | grep -c 'omnect-wifi-commissioning'
```
Expected: `0` (not installed on no-wifi machine).

- [ ] **Step 9: Commit**

```bash
git add recipes-omnect/omnect-wifi-commissioning recipes-omnect/images/omnect-os-image.bb
git commit -m "feat(wifi): add device_caps-driven oneshot orchestrator

Signed-off-by: Jan Zachmann <50990105+JanZachmann@users.noreply.github.com>"
```

---

### Task 5: remove udev hot-plug path and adjust wpa_supplicant unit

**Files:**
- Delete: `recipes-connectivity/wpa-supplicant/wpa-supplicant/80-wlan-wpa.rules`
- Modify: `recipes-connectivity/wpa-supplicant/wpa-supplicant_%.bbappend`
- Modify: `recipes-connectivity/wpa-supplicant/wpa-supplicant/wpa_supplicant@.service`

**Interfaces:**
- Consumes: nothing new. Produces: `wpa_supplicant@wlan0` started by Task 4's oneshot; still `Wants=wifi-commissioning-service@%i.service`.

- [ ] **Step 1: Delete the udev rule**

```bash
git rm recipes-connectivity/wpa-supplicant/wpa-supplicant/80-wlan-wpa.rules
```

- [ ] **Step 2: Remove udev wiring from the wpa bbappend**

In `recipes-connectivity/wpa-supplicant/wpa-supplicant_%.bbappend`:
- Remove `    file://80-wlan-wpa.rules\` from `SRC_URI`.
- Remove the two install lines:
  ```
      install -d ${D}${nonarch_base_libdir}/udev/rules.d
      install -m 0644 ${WORKDIR}/80-wlan-wpa.rules ${D}${nonarch_base_libdir}/udev/rules.d/80-wlan-wpa.rules
  ```
- Remove the line:
  ```
  FILES:${PN} += "${nonarch_base_libdir}/udev/rules.d/80-wlan-wpa.rules"
  ```

Resulting file:
```
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://wpa_supplicant.conf\
    file://wpa_supplicant@.service\
    "

do_install:append() {
    install -m 0644 ${WORKDIR}/wpa_supplicant.conf ${D}${sysconfdir}/wpa_supplicant.conf
    install -m 0644 ${WORKDIR}/wpa_supplicant@.service ${D}${systemd_system_unitdir}/wpa_supplicant@.service
}

inherit useradd

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM:${PN} = "-r wpa_supplicant;"
```

- [ ] **Step 3: Drop the hot-plug coupling from the service unit**

In `recipes-connectivity/wpa-supplicant/wpa-supplicant/wpa_supplicant@.service`, in the `[Unit]` section:
- Remove the two comment lines about `BindsTo`/udev and the `BindsTo=` line:
  ```
  # BindsTo (not Requires): stop the daemon when the adapter is removed.
  # Start-on-appearance comes from the 80-wlan-wpa.rules udev rule.
  BindsTo=sys-subsystem-net-devices-%i.device
  ```
- Keep `After=sys-subsystem-net-devices-%i.device`, `Before=network.target`, `Wants=network.target`, and `Wants=wifi-commissioning-service@%i.service`.

Resulting `[Unit]` head:
```
[Unit]
Description=WPA supplicant daemon
After=sys-subsystem-net-devices-%i.device
Before=network.target
Wants=network.target
Wants=wifi-commissioning-service@%i.service

StartLimitBurst=10
StartLimitIntervalSec=120
```

- [ ] **Step 4: Verify the udev rule is gone and the unit is clean**

In the `raspberrypi4-64` shell:
```bash
bitbake -e wpa-supplicant | grep -c '80-wlan-wpa.rules'   # expect 0
bitbake -c install wpa-supplicant
D=$(bitbake -e wpa-supplicant | sed -n 's/^D="\(.*\)"$/\1/p')
find "$D" -name '80-wlan-wpa.rules'                        # expect no output
grep -c '^BindsTo=' "$D/lib/systemd/system/wpa_supplicant@.service"          # expect 0
grep -c 'wifi-commissioning-service@%i.service' "$D/lib/systemd/system/wpa_supplicant@.service"  # expect 1
```
Expected: rule reference count 0; no rule file; `BindsTo` count 0; wcs `Wants` count 1.

- [ ] **Step 5: Commit**

```bash
git add recipes-connectivity/wpa-supplicant
git commit -m "refactor(wifi): drop udev hot-plug path; start wpa via oneshot

Signed-off-by: Jan Zachmann <50990105+JanZachmann@users.noreply.github.com>"
```

---

### Task 6: documentation

**Files:**
- Modify: `doc/wifi_commissioning.md` (rewrite)
- Modify: `README.md`, `doc/PHYTEC.md`, `doc/RASPBERRY-PI.md`, `doc/WELOTEC.md`

**Interfaces:** none (docs only).

- [ ] **Step 1: Read the current docs to find the exact wifi passages**

```bash
grep -n -i 'wifi\|commission\|udev\|wpa' doc/wifi_commissioning.md README.md doc/PHYTEC.md doc/RASPBERRY-PI.md doc/WELOTEC.md
```
Note each line that describes the old model (DISTRO feature `wifi-commissioning`, udev hot-plug, adapter-appears trigger).

- [ ] **Step 2: Rewrite `doc/wifi_commissioning.md`**

Replace its body so it documents the new model. Required content:
- Capabilities live in `/etc/omnect/device_caps.json`; keys `wifi`/`bluetooth` take `no | optional | yes`.
- Build time: `wifi != "no"` installs `wpa-supplicant` + `wifi-commissioning-service` + the `omnect-wifi-commissioning` oneshot; `bluetooth != "no"` (and wifi installed) compiles wcs with the `ble` cargo feature.
- Pre-boot editing: `optional` → `yes` before first boot to activate; build treats `optional` and `yes` identically.
- Runtime: the `omnect-wifi-commissioning` oneshot reads the file at boot; `wifi == "yes"` starts `wpa_supplicant@wlan0` (which pulls `wifi-commissioning-service@wlan0`); otherwise nothing starts. `bluetooth == "yes"` adds `--enable-ble`.
- No udev / no hot-plug; `wlan0` is assumed.
- BLE matrix:

  | `device_caps.bluetooth` | build: `ble` compiled? | runtime wcs arg | BLE state |
  |---|---|---|---|
  | `no` | no | (none) | off |
  | `optional` | yes | (none) | off (default) |
  | `yes` | yes | `--enable-ble` | on |

- [ ] **Step 3: Update the board/readme mentions**

For each match found in Step 1 in `README.md`, `doc/PHYTEC.md`, `doc/RASPBERRY-PI.md`, `doc/WELOTEC.md`: replace references to the removed `wifi-commissioning` DISTRO feature / kas example / udev hot-plug with a one-line pointer to `device_caps.json` and `doc/wifi_commissioning.md`. Do not invent new feature names; only correct the stale ones.

- [ ] **Step 4: Verify no stale references remain**

```bash
grep -n -i 'wifi-commissioning feature\|DISTRO_FEATURES.*wifi-commissioning\|udev\|hot-plug\|hotplug\|80-wlan-wpa' doc/wifi_commissioning.md README.md doc/PHYTEC.md doc/RASPBERRY-PI.md doc/WELOTEC.md
```
Expected: no matches describing the old model (matches only in unrelated contexts, if any, are acceptable — confirm each).

- [ ] **Step 5: Commit**

```bash
git add doc/wifi_commissioning.md README.md doc/PHYTEC.md doc/RASPBERRY-PI.md doc/WELOTEC.md
git commit -m "docs(wifi): document device_caps-driven commissioning model

Signed-off-by: Jan Zachmann <50990105+JanZachmann@users.noreply.github.com>"
```

---

### Task 7: integration build + verification (PREREQUISITE-GATED)

**Files:** none changed. This task builds and validates the whole chain.

**Interfaces:** consumes all prior tasks.

> **Do not start until the BUILD PREREQUISITE is met:** wcs source has the `ble` feature + `--enable-ble`, and the wcs recipe `SRCREV`/`PV` is bumped to that commit (a separate `chore(wifi-commissioning-service)` commit, following the existing SRCREV-bump commit pattern in this repo). Also confirm the ODS/wcs recipe source URLs point to the omnect org, not personal forks, before opening the PR.

- [ ] **Step 1: DISTRO_FEATURES before/after diff**

Using the baselines from Task 1 Step 1, in each machine's shell:
```bash
bitbake -e omnect-os-image | grep '^DISTRO_FEATURES=' > /tmp/distro-features-<machine>-after.txt
diff /tmp/distro-features-<machine>-before.txt /tmp/distro-features-<machine>-after.txt || true
```
Expected: differences are limited to `wifi`/`bluetooth` presence matching each machine's `device_caps.json` (per Global Constraints). Investigate any other feature that changed.

- [ ] **Step 2: Full build for the three machines**

Build each machine's image (via its dobi job / bitbake). Expected: all succeed, including `wifi-commissioning-service` compiling with `--features ble` on rpi4-64 and genericx86-64.

- [ ] **Step 3: Package-manifest sanity for genericx86-64**

`genericx86-64` has `bluetooth:"optional"`, so it now derives `DISTRO_FEATURES bluetooth`. Inspect the image manifest:
```bash
grep -iE 'bluez|wpa-supplicant|wifi-commissioning|omnect-wifi-commissioning' <deploy>/…/*.manifest
```
Expected: `wpa-supplicant`, `wifi-commissioning-service`, `omnect-wifi-commissioning`, and the bluez stack are present. Confirm this bluetooth-stack inclusion is intended for genericx86-64 (it is the documented consequence of `bluetooth:"optional"` + `wifi:"optional"`); if not, the machine's `device_caps.json` must set `bluetooth:"no"`.

- [ ] **Step 4: Runtime smoke verification (hardware/CI)**

On a device farm target (or by editing `device_caps.json` on a flashed image before first boot), verify each case via `ci/tests/base_test.sh` / manual `systemctl`:
- `wifi:"yes"`: after boot, `omnect-wifi-commissioning.service` succeeded (oneshot, active/exited); `wpa_supplicant@wlan0` and `wifi-commissioning-service@wlan0` are `active`; `/run/omnect-wifi-commissioning.env` exists.
- `wifi:"optional"` (unedited): the wifi/wcs units are installed but `inactive`; the oneshot exited 0 without starting them.
- `bluetooth:"yes"`: `wifi-commissioning-service@wlan0` `ExecStart` effective command includes `--enable-ble` (`systemctl show -p ExecStart wifi-commissioning-service@wlan0`), and ODS reports `ble_enabled: true`.
- Confirm the oneshot did not deadlock boot (no `systemd` job timeout; boot completes) — validates spec risk #4.

- [ ] **Step 5: Update whitelists if needed**

Run the smoke test; if the new oneshot/start path emits expected syslog noise, add POSIX-ERE entries to the affected `ci/tests/whitelists/<device>/<branch>/*.json`. With the udev rule gone, confirm no new hot-plug/wpa log errors appear. Commit any whitelist change:
```bash
git add ci/tests/whitelists
git commit -m "test(wifi): whitelist device_caps oneshot log output

Signed-off-by: Jan Zachmann <50990105+JanZachmann@users.noreply.github.com>"
```

- [ ] **Step 6: PR logistics (decided: continue on `chore`, new PR, close #664)**

Work stays on `chore` (already `upstream/main` + the reused groundwork; carries the
pre-existing mixed secure-boot/ODS-bump commits). Push `chore`, then:
```bash
gh pr close 664 --comment "Superseded by the device_caps.json-driven design; see new PR."
gh pr create --base main --head chore --repo omnect/meta-omnect \
  --title "feat(wifi): drive commissioning from device_caps.json" \
  --body "<Summary / Reason / Verification per CLAUDE.md>"
```
(`--base main` targets `upstream/main` = omnect org. A branch hosts one open PR per
base, so #664 must be closed before opening the new one from `chore`.) PR body sections:
Summary (device_caps single source, oneshot runtime, udev removed), Reason (remove the
MACHINE_FEATURES/device_caps divergence; runtime-selectable wifi/BLE), Verification
(before/after DISTRO_FEATURES + manifest diff, three-machine build, hardware smoke).

---

## Self-Review

**Spec coverage:**
- §4.1 bbclass → Task 1. §4.2 DISTRO_FEATURES (wifi + bluetooth-gated-on-wifi, 3g untouched) → Task 1. §4.3 systemd gate → Task 2. §4.4 wcs ble cargo feature + drop disable-ble sed → Task 3. §4.5 image install unchanged (extended to add oneshot) → Task 4 Step 7.
- §5.1 remove udev → Task 5. §5.2 oneshot recipe/service/script → Task 4. §5.3 wpa unit → Task 5. §5.4 wcs @.service EnvironmentFile + arg → Task 3 Step 2. §5.5 bluez unchanged → no task (correct).
- §6 BLE matrix → Tasks 3/4 + documented in Task 6. §7 dependencies → Global Constraints + Task 7 gate. §8 docs → Task 6. §9 testing (before/after DISTRO_FEATURES, manifest diff, build, smoke) → Task 7. §10 logistics → Task 7 Step 6. §11 risks: #1 mark_dependency → Task 1 (verified via clean parse); #2 bluetooth ordering inert → Task 3 (kept, non-bt drops it); #3 wpa start ordering + #4 boot-transaction race → Task 4 (`--no-block`, no `Before=network.target`) + Task 7 Step 4.

**Deviation from spec (intentional, resolves risk #4):** the oneshot omits `Before=network.target` and uses `systemctl start --no-block`, avoiding a synchronous start inside the boot transaction. BLE token is `$$WCS_BLE_ARGS` (no braces) to avoid BitBake `${...}` expansion.

**Placeholder scan:** none — every code/step is concrete.

**Type/name consistency:** `omnect_device_cap` (Task 1) used only in Task 1. `cap()` companion `omnect-wifi-commissioning-start.capfn` consistent across Task 4 Steps 1/3/6. `WCS_BLE_ARGS` consistent across Task 3 (unit) and Task 4 (env writer). Unit/service names (`omnect-wifi-commissioning.service`, `wpa_supplicant@wlan0.service`, `wifi-commissioning-service@wlan0.service`) consistent across Tasks 3/4/5.
