# Mandatory Access Control (AppArmor)

AppArmor is a **Linux Security Module (LSM)** — the Linux kernel's framework for
Mandatory Access Control (MAC). `omnect-os` images ship with AppArmor compiled
into the kernel and its userspace tooling installed, but **DAC (discretionary
access control) remains the default**. No MAC is active out of the box, so default
device behavior is unchanged. AppArmor can be activated per device via the kernel
command line.

> **Note:** Only **one** "major" LSM can be active per boot. AppArmor is the major
> LSM compiled into `omnect-os`; you select it (or none) on the kernel command line.

## What is included

Kernel (always, all machines):

- `CONFIG_SECURITY_APPARMOR=y` — see `recipes-kernel/linux/files/audit.cfg`
- `CONFIG_DEFAULT_SECURITY_DAC=y` — DAC stays the default; AppArmor does not
  initialize unless selected at boot.
- `CONFIG_LSM="landlock,lockdown,yama,loadpin,safesetid,bpf"` — see
  `recipes-kernel/linux/files/audit.cfg`. The active LSM list is pinned to the minor
  LSMs only (no major MAC LSM). AppArmor is activated by appending it to this list
  via `lsm=` on the kernel command line (see [Enabling AppArmor](#enabling-apparmor)).

Userspace (via `DISTRO_FEATURES += "apparmor"`, installed through
`OMNECT_MAC_USERSPACE` in `recipes-omnect/images/omnect-os-image.bb`):

- `apparmor` — parser, `libapparmor`, `aa-*` tools, `apparmor.service`

> **No profiles ship by default.** AppArmor can be *enabled* at boot, but nothing
> is confined until profiles are loaded. `apparmor.service` loads any profiles
> present at boot; see the [IoT Edge example](#example-confining-an-iot-edge-module)
> for adding one.

## Checking the current state

```bash
# Authoritative: which LSMs are active this boot.
# DAC default => apparmor is NOT listed; once enabled it appears here.
cat /sys/kernel/security/lsm

# AppArmor detail (only meaningful once apparmor is in the list above)
aa-status
# Reflects the compile/boot-param default and can read 'Y' even when apparmor is
# NOT the active LSM — trust /sys/kernel/security/lsm and aa-status instead.
cat /sys/module/apparmor/parameters/enabled
```

## Enabling AppArmor

Add to the kernel command line:

```
lsm=landlock,lockdown,yama,loadpin,safesetid,bpf,apparmor
```

This is the pinned `CONFIG_LSM` list (see [What is included](#what-is-included))
with `apparmor` appended. AppArmor is enabled once it appears in the list, so no
separate `apparmor=1` is needed. `apparmor.service` then loads any installed
profiles at boot. Verify AppArmor is active by confirming `apparmor` now appears in
`/sys/kernel/security/lsm` and that `aa-status` reports it loaded.

> **Why `lsm=` and not `security=`?** The legacy `security=apparmor` parameter only
> *filters* among the major LSMs already present in `CONFIG_LSM`; it never *adds*
> one. Since DAC is the default, apparmor is not in the pinned list, so `security=`
> alone activates nothing. `lsm=` replaces the whole list, which is how AppArmor
> gets in.

## Setting the kernel command line

The LSM is selected per device at runtime, with no image rebuild. Append your
arguments to the customer bootargs file and push them into the bootloader
environment; they take effect on the next boot:

```bash
echo "lsm=landlock,lockdown,yama,loadpin,safesetid,bpf,apparmor" | sudo tee -a /boot/omnect_extra_bootargs_custom
sudo omnect_extra_bootargs.sh set
sudo reboot
```

The merged value of `/boot/omnect_extra_bootargs_omnect` (set by the OS/updates)
and `/boot/omnect_extra_bootargs_custom` (customer) is stored as the bootloader
environment variable `omnect_extra_bootargs` and appended to the kernel command
line on the next boot. See
`recipes-omnect/omnect-base-files/omnect-base-files/usr/bin/omnect_extra_bootargs.sh`.

## Example: confining an IoT Edge module

[`examples/iotedge-apparmor/`](examples/iotedge-apparmor/) deploys the Azure IoT Edge
SimulatedTemperatureSensor "hello world" module and confines its container with a custom
AppArmor profile (referenced from the deployment via
`HostConfig.SecurityOpt: ["apparmor=<name>"]`). See its [`README.md`](examples/iotedge-apparmor/README.md) for the full
load/apply/verify walkthrough.

## Limitations and future work

- Only **one** major LSM can enforce per boot, and AppArmor is not active by
  default (DAC stays the default).
- **No AppArmor profiles ship in the base image.** Confinement is opt-in: load a
  profile (e.g. via the IoT Edge example above) before AppArmor restricts anything.
