# aziot identity recovery design

Fixes the dead end described in `aziot-identity-recovery-issue.md`: a missing
`/etc/aziot/identityd/config.d/00-super.toml` fails `aziot-identityd.socket`
via its trigger limit, a late successful `config apply` starts nothing, and
the ADU agent exhausts its start limit — the device stays `degraded` with no
identity until `deviceupdate-agent.timer` fires.

Scope: unit-file changes in meta-omnect only, no source patches. The
companion test change (remove the transitional `repair_identity_units` step
from `ci/tests/precondition_recovery_test.sh`) is a separate omnect-os PR.

Each of the three fixes removes the dead end on its own; together they make
recovery fast and independent of which client happens to run.

## 1. Sockets never fail from skipped activations

Add `TriggerLimitIntervalSec=0` under `[Socket]` for:

- `aziot-identityd.socket`, `aziot-keyd.socket`, `aziot-certd.socket`,
  `aziot-tpmd.socket` — in `aziot-identityd.inc`, same sed style as the
  service edits
- `aziot-edged.mgmt.socket`, `aziot-edged.workload.socket` — in
  `aziot-edged.inc`; `aziot-edged.service` carries the same
  `ConditionPathExists` lines, so its sockets share the dead end

While the service is skipped by its condition the socket stays listening; the
first client connect after the super config is back activates the service.

Load-bearing assumption, verify on a device: a pending connection to a
skipped service must not busy-loop systemd. On systemd 255 the poll limit
(`PollLimitIntervalSec`, active by default) pauses polling instead of failing
the unit. meta-omnect main is scarthgap-only (systemd 255.21).

## 2. Late `config apply` starts the stack

`aziot-identityd-precondition.service` gets

    ExecStartPost=-/bin/systemctl start --no-block aziot-identityd.service

Starting identityd is enough for the rest of the identity stack: identityd's
connects to the keyd/certd/tpmd sockets activate those services. On
iotedge distros the recipe's existing `DISTRO_FEATURES` branch (the
`@@AZIOTCLI@@` substitution) adds `aziot-edged.service` to the started units;
edged needs its own start.

- `--no-block` is mandatory: the precondition is ordered `Before=` these
  units, a blocking start inside `ExecStartPost` deadlocks.
- On a normal boot the start merges with the already-queued jobs (no-op).
- The `-` prefix keeps a failed `systemctl` call from failing an otherwise
  successful apply.

## 3. ADU agent retries forever with backoff

`deviceupdate-agent.service`: drop `StartLimitBurst`, set
`StartLimitIntervalSec=0`, keep `Restart=always`, add `RestartSteps=5` and
`RestartMaxDelaySec=60` on top of `RestartSec=5` (delay grows from 5 s to
60 s). Needs systemd >= 254; scarthgap has 255.

- Each auto-restart re-queues `Wants=aziot-identityd.service`, so the agent
  is a recovery path for identity too.
- The unit never reaches `failed`; a persistent loop is visible through the
  crash-loop checker. Planning-time check: does the checker's threshold still
  flag a loop that has slowed to one restart per 60 s?
- `deviceupdate-agent.timer` stays unchanged — its job is the
  skipped-at-boot case (condition blocked the start, `Restart=` never
  engaged), not start-limit rescue.

## Verification

- Manual repro from the issue doc on an rpi4: socket survives the
  config-less window, identityd comes up right after a successful apply, the
  agent within `RestartMaxDelaySec`.
- omnect-os follow-up: `precondition_recovery_test.sh` loses
  `repair_identity_units` and its TODO; `RECOVER_DEADLINE` grows to cover one
  `RestartMaxDelaySec` (~90 s).
- Whitelist check: the failure window now produces repeated "skipped because
  of an unmet condition" lines instead of a one-time trigger-limit failure;
  base_test's syslog check may need a whitelist entry.

## Commits

One commit per fix, the socket fix split by recipe:

1. `fix(aziot-identityd): keep sockets active while the service is skipped`
2. `fix(aziot-edged): keep sockets active while the service is skipped`
3. `fix(aziot-identityd): start the identity stack after a late config apply`
4. `fix(adu): retry forever with backoff instead of reaching the start limit`
