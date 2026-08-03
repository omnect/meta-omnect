# aziot identity recovery implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the identity dead end: sockets survive skipped activations, a late `config apply` starts the stack, the ADU agent retries forever with backoff.

**Architecture:** Unit-file changes only, applied through the Yocto recipes in meta-omnect. No source patches. Spec: `docs/superpowers/specs/2026-08-03-aziot-identity-recovery-design.md`.

**Tech Stack:** BitBake recipes (`.inc`, `.bbclass`), systemd unit files, bash.

## Global Constraints

- Branch: `jz-2026-08-03-aziot-identity-recovery` (off `upstream/main`), repo `/home/jzac/projects/meta-omnect`.
- Target systemd is 255.21 (scarthgap); `RestartSteps`/`RestartMaxDelaySec` (need >= 254) are available.
- `systemctl` lives at `/bin/systemctl` on the target (no `usrmerge` in `DISTRO_FEATURES`).
- Every commit message ends with `Signed-off-by: Jan Zachmann <50990105+JanZachmann@users.noreply.github.com>`.
- Comments in unit files/recipes: short, explain only the why, no PR/issue references, no version numbers.
- There is no unit-test suite in this repo. Each task verifies its sed/edit against a fixture in the scratchpad (`/tmp/claude-1000/-home-jzac-projects-omnect-os/1d9ec82f-888d-46f1-9563-aeaf209297ae/scratchpad`), the final task builds an image and verifies on a device.

**Out of scope:** the omnect-os test change (drop `repair_identity_units` from `ci/tests/precondition_recovery_test.sh`, raise `RECOVER_DEADLINE`, whitelist check) — separate PR in omnect-os after this is merged.

---

### Task 1: identity sockets survive skipped activations

**Files:**
- Modify: `classes/aziot.bbclass` (add helper at end of file)
- Modify: `recipes-azure-iot/azure-identityd/aziot-identityd.inc` (4 socket install sites)

**Interfaces:**
- Produces: shell function `aziot_disable_socket_trigger_limit <unit-file-path>`, defined in `classes/aziot.bbclass`, usable from `do_install` of every recipe that inherits `aziot`. Task 2 calls it.

Background: `aziot-identityd.service` (and keyd/certd/tpmd) carry `ConditionPathExists=` on the aziot super config. While the config is missing, every socket activation is skipped instantly and counts against the socket's default trigger limit (20 in 2 s); when hit, the socket fails and is never activated again. `TriggerLimitIntervalSec=0` disables the limit, so the socket stays listening and the first connect after the config is back activates the service. On systemd 255 the poll limit (on by default) throttles rapid re-triggering by pausing polling, so no busy loop.

- [ ] **Step 1: Add the helper to `classes/aziot.bbclass`**

Append at the end of the file:

```sh
# a service skipped by its condition must not fail its socket through the
# trigger limit: without the limit the socket stays listening, and the first
# connect after the condition turns true activates the service
aziot_disable_socket_trigger_limit() {
    sed -i 's/^\[Socket\]$/[Socket]\nTriggerLimitIntervalSec=0/' "$1"
}
```

- [ ] **Step 2: Call it for the four sockets in `aziot-identityd.inc`**

After each socket's `fill_placeholders` line, add the helper call. The four sites (line numbers from current `upstream/main`):

`aziot-identityd.inc:133` (certd):
```sh
    fill_placeholders ${D}${systemd_system_unitdir}/aziot-certd.socket
    aziot_disable_socket_trigger_limit ${D}${systemd_system_unitdir}/aziot-certd.socket
```

`aziot-identityd.inc:149` (identityd):
```sh
    fill_placeholders ${D}${systemd_system_unitdir}/aziot-identityd.socket
    aziot_disable_socket_trigger_limit ${D}${systemd_system_unitdir}/aziot-identityd.socket
```

`aziot-identityd.inc:161` (keyd):
```sh
    fill_placeholders ${D}${systemd_system_unitdir}/aziot-keyd.socket
    aziot_disable_socket_trigger_limit ${D}${systemd_system_unitdir}/aziot-keyd.socket
```

`aziot-identityd.inc:174` (tpmd, inside the `tpm2` branch):
```sh
        fill_placeholders ${D}${systemd_system_unitdir}/aziot-tpmd.socket
        aziot_disable_socket_trigger_limit ${D}${systemd_system_unitdir}/aziot-tpmd.socket
```

- [ ] **Step 3: Verify the sed against a fixture**

The upstream socket files all have a plain `[Socket]` line (verified at SRCREV `833381a` for identityd/keyd/certd/tpmd). Reproduce one and run the exact sed:

```bash
SCRATCH=/tmp/claude-1000/-home-jzac-projects-omnect-os/1d9ec82f-888d-46f1-9563-aeaf209297ae/scratchpad
cat > ${SCRATCH}/fixture.socket <<'EOF'
[Unit]
Description=Azure IoT Identity Service API socket
PartOf=aziot-identityd.service

[Socket]
ListenStream=@socket_dir@/identityd.sock
SocketMode=0660
DirectoryMode=0755
SocketUser=@user_aziotid@
SocketGroup=@user_aziotid@

[Install]
WantedBy=sockets.target
EOF
sed -i 's/^\[Socket\]$/[Socket]\nTriggerLimitIntervalSec=0/' ${SCRATCH}/fixture.socket
grep -A1 '^\[Socket\]$' ${SCRATCH}/fixture.socket
```

Expected output:
```
[Socket]
TriggerLimitIntervalSec=0
```

- [ ] **Step 4: Commit**

```bash
cd /home/jzac/projects/meta-omnect
git add classes/aziot.bbclass recipes-azure-iot/azure-identityd/aziot-identityd.inc
git commit -m "fix(aziot-identityd): keep sockets active while the service is skipped

While the aziot super config is missing, aziot-identityd.service (and
keyd/certd/tpmd) are skipped by their ConditionPathExists. Each skipped
activation counts against the socket's default trigger limit (20 in 2s),
so one reconnecting client fails the socket, and a failed socket is never
activated again - the device keeps no path back to a working identity.

Disable the trigger limit on the aziot sockets. The socket then stays
listening while the service is skipped, and the first client connect after
the config is back activates the service. Rapid re-triggering is throttled
by systemd's poll limit instead of failing the unit.

Signed-off-by: Jan Zachmann <50990105+JanZachmann@users.noreply.github.com>"
```

---

### Task 2: edged sockets survive skipped activations

**Files:**
- Modify: `dynamic-layers/virtualization/recipes-azure-iot/iotedge/aziot-edged/aziot-edged.inc` (2 socket install sites in `do_install`)

**Interfaces:**
- Consumes: `aziot_disable_socket_trigger_limit <unit-file-path>` from `classes/aziot.bbclass` (Task 1). The recipe already inherits `aziot`.

`aziot-edged.service` carries the same two `ConditionPathExists` lines (added by this recipe's `do_install` sed), so its two sockets have the same dead end.

- [ ] **Step 1: Add the helper calls**

In `do_install`, directly after the two socket installs:

```sh
    install -m 0644 ${S}/edgelet/contrib/systemd/debian/aziot-edged.workload.socket  ${D}${systemd_system_unitdir}/aziot-edged.workload.socket
    install -m 0644 ${S}/edgelet/contrib/systemd/debian/aziot-edged.mgmt.socket  ${D}${systemd_system_unitdir}/aziot-edged.mgmt.socket
    aziot_disable_socket_trigger_limit ${D}${systemd_system_unitdir}/aziot-edged.workload.socket
    aziot_disable_socket_trigger_limit ${D}${systemd_system_unitdir}/aziot-edged.mgmt.socket
```

- [ ] **Step 2: Verify the sed against the edged fixture**

The upstream edged sockets also have a plain `[Socket]` line (verified at SRCREV `306856c`):

```bash
SCRATCH=/tmp/claude-1000/-home-jzac-projects-omnect-os/1d9ec82f-888d-46f1-9563-aeaf209297ae/scratchpad
cat > ${SCRATCH}/edged-fixture.socket <<'EOF'
[Unit]
Description=Azure IoT Edge daemon management socket
Documentation=man:aziot-edged(8)
PartOf=aziot-edged.service

[Socket]
ListenStream=/var/run/iotedge/mgmt.sock
SocketMode=0660
DirectoryMode=0755
SocketUser=edgeagentuser
SocketGroup=iotedge
Service=aziot-edged.service

[Install]
WantedBy=sockets.target
EOF
sed -i 's/^\[Socket\]$/[Socket]\nTriggerLimitIntervalSec=0/' ${SCRATCH}/edged-fixture.socket
grep -A1 '^\[Socket\]$' ${SCRATCH}/edged-fixture.socket
```

Expected output:
```
[Socket]
TriggerLimitIntervalSec=0
```

- [ ] **Step 3: Commit**

```bash
cd /home/jzac/projects/meta-omnect
git add dynamic-layers/virtualization/recipes-azure-iot/iotedge/aziot-edged/aziot-edged.inc
git commit -m "fix(aziot-edged): keep sockets active while the service is skipped

aziot-edged.service carries the same ConditionPathExists on the aziot
super config as the identity services, so its mgmt and workload sockets
can fail through the trigger limit the same way. Disable the limit so the
sockets stay listening and the first connect after the config is back
activates edged.

Signed-off-by: Jan Zachmann <50990105+JanZachmann@users.noreply.github.com>"
```

---

### Task 3: late `config apply` starts the stack

**Files:**
- Modify: `recipes-azure-iot/azure-identityd/aziot-identityd/aziot-identityd-precondition.service`
- Modify: `recipes-azure-iot/azure-identityd/aziot-identityd.inc` (the `@@AZIOTCLI@@` substitution block, lines 188-192)

**Interfaces:**
- Produces: placeholder `@@STACK_UNITS@@` in the precondition unit, substituted by `aziot-identityd.inc`'s `do_install`. Internal to this task.

Background: on a normal boot the precondition is ordered `Before=` the aziot services and they start in the same transaction. When the unit runs after boot (its timer, the update-validation flags), a successful `config apply` only writes the config - nothing starts the services, and a client connect is the only trigger left. Starting identityd from `ExecStartPost` closes that gap; identityd's connects to the keyd/certd/tpmd sockets activate those services. edged is not pulled by identityd and needs its own start on iotedge distros.

- [ ] **Step 1: Add `ExecStartPost` to the precondition unit**

In `aziot-identityd-precondition.service`, `[Service]` section, after the `ExecStart` line:

```ini
[Service]
Type=oneshot
ExecStart=@@AZIOTCLI@@ config apply
# a run after boot only writes the config; bring the services up like the
# boot transaction would. --no-block is required: this unit is ordered
# Before= the started units, a blocking start would deadlock. On a normal
# boot the request merges with the already queued jobs.
ExecStartPost=-/bin/systemctl start --no-block @@STACK_UNITS@@
Restart=on-failure
RestartSec=5
RemainAfterExit=true
```

- [ ] **Step 2: Substitute `@@STACK_UNITS@@` in `aziot-identityd.inc`**

Extend the existing `DISTRO_FEATURES` branch (currently only substituting `@@AZIOTCLI@@`):

```sh
    if ${@bb.utils.contains('DISTRO_FEATURES', 'iotedge', 'true', 'false', d)}; then
        sed -i "s/@@AZIOTCLI@@/iotedge/" ${D}${systemd_system_unitdir}/aziot-identityd-precondition.service
        sed -i "s/@@STACK_UNITS@@/aziot-identityd.service aziot-edged.service/" ${D}${systemd_system_unitdir}/aziot-identityd-precondition.service
    else
        sed -i "s/@@AZIOTCLI@@/aziotctl/" ${D}${systemd_system_unitdir}/aziot-identityd-precondition.service
        sed -i "s/@@STACK_UNITS@@/aziot-identityd.service/" ${D}${systemd_system_unitdir}/aziot-identityd-precondition.service
    fi
```

- [ ] **Step 3: Verify both substitution variants**

```bash
SCRATCH=/tmp/claude-1000/-home-jzac-projects-omnect-os/1d9ec82f-888d-46f1-9563-aeaf209297ae/scratchpad
src=/home/jzac/projects/meta-omnect/recipes-azure-iot/azure-identityd/aziot-identityd/aziot-identityd-precondition.service
sed "s/@@STACK_UNITS@@/aziot-identityd.service aziot-edged.service/" $src | grep ExecStartPost
sed "s/@@STACK_UNITS@@/aziot-identityd.service/" $src | grep ExecStartPost
grep -c "@@" $src
```

Expected:
```
ExecStartPost=-/bin/systemctl start --no-block aziot-identityd.service aziot-edged.service
ExecStartPost=-/bin/systemctl start --no-block aziot-identityd.service
2
```
(the `2` = the two remaining placeholders in the source file: `@@AZIOTCLI@@` and `@@STACK_UNITS@@`)

- [ ] **Step 4: Commit**

```bash
cd /home/jzac/projects/meta-omnect
git add recipes-azure-iot/azure-identityd/aziot-identityd/aziot-identityd-precondition.service recipes-azure-iot/azure-identityd/aziot-identityd.inc
git commit -m "fix(aziot-identityd): start the identity stack after a late config apply

When the precondition unit runs after boot (timer, update-validation
flags), a successful 'config apply' only writes the configuration and
nothing starts the identity services. Start them from ExecStartPost so
the after-boot path behaves like the boot path. identityd's connects to
the keyd/certd/tpmd sockets activate those services; edged needs its own
start on iotedge distros.

Signed-off-by: Jan Zachmann <50990105+JanZachmann@users.noreply.github.com>"
```

---

### Task 4: ADU agent retries forever with backoff

**Files:**
- Modify: `recipes-azure-iot/iot-hub-device-update/iot-hub-device-update/deviceupdate-agent.service`

**Interfaces:** none (self-contained unit change).

Background: the agent exits with code 1 when its startup health check cannot reach identityd. With `StartLimitBurst=10`/`StartLimitIntervalSec=120` an identity outage of ~50 s parks the unit in `failed`, and only `deviceupdate-agent.timer` (minutes) starts it again. Retry forever instead: each auto-restart also re-queues `Wants=aziot-identityd.service`, so the agent is itself a recovery path for identity. A persistent loop stays visible: the crash-loop check keys on the `activating (auto-restart)` sub-state, which the unit occupies during every backoff delay.

- [ ] **Step 1: Edit the unit**

In the `[Unit]` section, replace

```ini
StartLimitBurst=10
StartLimitIntervalSec=120
```

with

```ini
# never park in 'failed': each restart also pulls identity up again via
# Wants=, and a persistent loop is caught by the crash-loop check
StartLimitIntervalSec=0
```

In the `[Service]` section, replace

```ini
Restart=always
RestartSec=5
```

with

```ini
Restart=always
RestartSec=5
RestartSteps=5
RestartMaxDelaySec=60
```

- [ ] **Step 2: Verify the resulting unit**

```bash
grep -E "StartLimit|Restart" /home/jzac/projects/meta-omnect/recipes-azure-iot/iot-hub-device-update/iot-hub-device-update/deviceupdate-agent.service
```

Expected (exactly these, no `StartLimitBurst` left):
```
StartLimitIntervalSec=0
Restart=always
RestartSec=5
RestartSteps=5
RestartMaxDelaySec=60
```

- [ ] **Step 3: Commit**

```bash
cd /home/jzac/projects/meta-omnect
git add recipes-azure-iot/iot-hub-device-update/iot-hub-device-update/deviceupdate-agent.service
git commit -m "fix(adu): retry forever with backoff instead of reaching the start limit

The agent exits when its startup health check cannot reach identityd,
and ~50 s of identity outage used to park the unit in 'failed' until the
retry timer fired minutes later. Drop the start limit and back the
restart delay off from 5 s to 60 s: the agent recovers within one delay
once identity is back, and each restart pulls identityd up again through
its Wants=. A persistent loop is still flagged by the crash-loop check,
which keys on the auto-restart sub-state.

Signed-off-by: Jan Zachmann <50990105+JanZachmann@users.noreply.github.com>"
```

---

### Task 5: build and device verification

**Files:** none (verification only, no commit).

- [ ] **Step 1: Build a gateway-devel image with the branch**

Make sure `local.env` in `/home/jzac/projects/omnect-os` points kas at the local meta-omnect checkout (branch `jz-2026-08-03-aziot-identity-recovery`), then:

```bash
cd /home/jzac/projects/omnect-os
./dobi.sh build-omnect-gateway-devel-rpi4-64
```

- [ ] **Step 2: Inspect the generated units in the build tree**

```bash
cd /home/jzac/projects/omnect-os
find build/build/tmp*/work -path "*aziot*" -name "*.socket" -exec grep -l TriggerLimitIntervalSec {} \;
find build/build/tmp*/work -name "aziot-identityd-precondition.service" -path "*image*" -exec grep ExecStartPost {} \;
find build/build/tmp*/work -name "deviceupdate-agent.service" -path "*image*" -exec grep -E "StartLimit|RestartSteps" {} \;
```

Expected: all aziot sockets contain `TriggerLimitIntervalSec=0`; the precondition unit contains the substituted `ExecStartPost` (no `@@` left); the agent unit has `StartLimitIntervalSec=0`, `RestartSteps=5`, `RestartMaxDelaySec=60`.

- [ ] **Step 3: Manual repro on an rpi4 (gateway-devel)**

Flash the image, then run the repro from the issue doc:

```bash
sudo systemctl stop aziot-identityd.service
sudo rm /etc/aziot/identityd/config.d/00-super.toml
sudo systemctl restart deviceupdate-agent.service
sleep 60
journalctl -b0 | grep -c 'Trigger limit'          # expected: 0
systemctl is-active aziot-identityd.socket         # expected: active
systemctl show -p ActiveState,SubState,NRestarts deviceupdate-agent.service
# expected: activating / auto-restart, NRestarts growing, never 'failed'
```

Then restore and watch recovery:

```bash
sudo systemctl start aziot-identityd-precondition.service   # regenerates the super config via config apply
systemctl is-active aziot-identityd.service        # expected: active right after apply (fix b)
sleep 90
systemctl is-active deviceupdate-agent.service     # expected: active within RestartMaxDelaySec
systemctl is-system-running                        # expected: running
```

Also confirm the load-bearing assumption of fix (a): while the super config is missing, `journalctl -f` must not show a skip-loop storm faster than the poll limit allows, and systemd's CPU usage stays normal.

- [ ] **Step 4: Report results**

No commit. Record the device observations in the PR conversation (not the description).
