# Mandatory Access Control (AppArmor / SELinux)

AppArmor and SELinux are **Linux Security Modules (LSM)** — the Linux kernel's
framework for Mandatory Access Control (MAC). `omnect-os` images ship with **both**
LSMs compiled into the kernel and their userspace tooling installed, but **DAC
(discretionary access control) remains the default**. No MAC is active out of the
box, so default device behavior is unchanged. AppArmor or SELinux can be activated
per device via the kernel command line.

> **Note:** AppArmor and SELinux are *mutually exclusive* at runtime. The kernel
> can only have **one** active "major" LSM per boot — you select which one (or
> none) on the kernel command line.

## What is included

Kernel (always, all machines):

- `CONFIG_SECURITY_APPARMOR=y` — see `recipes-kernel/linux/files/audit.cfg`
- `CONFIG_SECURITY_SELINUX=y` (+ `..._BOOTPARAM`, `..._AVC_STATS`) — see
  `recipes-kernel/linux/files/selinux.cfg`
- `CONFIG_DEFAULT_SECURITY_DAC=y` — DAC stays the default; neither LSM initializes
  unless selected at boot.
- `CONFIG_LSM="landlock,lockdown,yama,loadpin,safesetid,bpf"` — see
  `recipes-kernel/linux/files/audit.cfg`. The active LSM list is pinned to the minor
  LSMs only (no major MAC LSM). A major LSM is activated by appending it to this list
  via `lsm=` on the kernel command line (see [Enabling AppArmor](#enabling-apparmor)).

Userspace (via `DISTRO_FEATURES += "apparmor selinux acl"`, installed through
`OMNECT_MAC_USERSPACE` in `recipes-omnect/images/omnect-os-image.bb`):

- AppArmor: `apparmor` (parser, `libapparmor`, `aa-*` tools, `apparmor.service`)
- SELinux: `libselinux(-bin)`, `libsemanage`, `libsepol`, `checkpolicy`,
  `policycoreutils-{loadpolicy,semodule,sestatus,setfiles}`

> **SELinux is framework/userspace only.** No reference policy ships and the
> system is not enforcing. SELinux can be *enabled* (it will run permissive with
> no policy), but a policy must be built/loaded and the filesystem labeled before
> it does anything useful — see [Limitations](#limitations-and-future-work).

## Checking the current state

```bash
# which LSMs are active this boot (DAC default => no apparmor/selinux listed)
cat /sys/kernel/security/lsm

# AppArmor
aa-status

# SELinux
sestatus
getenforce
```

## Enabling AppArmor

Add to the kernel command line:

```
lsm=landlock,lockdown,yama,loadpin,safesetid,bpf,apparmor
```

This is the pinned `CONFIG_LSM` list (see [What is included](#what-is-included))
with `apparmor` appended. AppArmor is enabled once it appears in the list, so no
separate `apparmor=1` is needed. `apparmor.service` then loads any installed
profiles at boot. Verify with `aa-status` and
`cat /sys/module/apparmor/parameters/enabled` (`Y`).

## Enabling SELinux

Add to the kernel command line:

```
lsm=landlock,lockdown,yama,loadpin,safesetid,bpf,selinux selinux=1
```

With no policy present, SELinux comes up disabled/permissive — this is expected
for the current framework-only state.

> **Why `lsm=` and not `security=`?** The legacy `security=apparmor`/`security=selinux`
> parameter only *filters* among the major LSMs already present in `CONFIG_LSM`; it
> never *adds* one. Since DAC is the default, neither apparmor nor selinux is in the
> pinned list, so `security=` alone activates nothing. `lsm=` replaces the whole list,
> which is how the chosen LSM gets in. List **only one** major LSM (apparmor *or*
> selinux) — they are mutually exclusive at runtime.

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
`HostConfig.SecurityOpt: ["apparmor=<name>"]`). See its `README.md` for the full
load/apply/verify walkthrough.

## Limitations and future work

- Only **one** LSM (AppArmor *or* SELinux) can enforce per boot.
- **SELinux enforcing is not yet supported.** The rootfs is a read-only A/B
  ext4 layout (`rootA`/`rootB`) with an overlayfs on `/etc` and `/home`. ext4
  xattr/ACL are enabled (`recipes-kernel/linux/files/enable-ext4-fs-security.cfg`),
  so labeling is possible, but a read-only rootfs requires **build-time file
  labeling** rather than first-boot relabeling, plus a reference policy
  (`refpolicy`). That is a separate, larger effort.
- `pam` is not a `DISTRO_FEATURE`, so login-time SELinux context switching
  (`pam_selinux`) is not wired up yet.
