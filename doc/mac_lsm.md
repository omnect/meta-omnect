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
security=apparmor apparmor=1
```

`apparmor.service` then loads any installed profiles at boot. Verify with
`aa-status` and `cat /sys/module/apparmor/parameters/enabled` (`Y`).

## Enabling SELinux

Add to the kernel command line:

```
security=selinux selinux=1
```

With no policy present, SELinux comes up disabled/permissive — this is expected
for the current framework-only state.

## Setting the kernel command line

The LSM is selected per device at runtime, with no image rebuild. Append your
arguments to the customer bootargs file and push them into the bootloader
environment; they take effect on the next boot:

```bash
echo "security=apparmor apparmor=1" | sudo tee -a /boot/omnect_extra_bootargs_custom
sudo omnect_extra_bootargs.sh set
sudo reboot
```

The merged value of `/boot/omnect_extra_bootargs_omnect` (set by the OS/updates)
and `/boot/omnect_extra_bootargs_custom` (customer) is stored as the bootloader
environment variable `omnect_extra_bootargs` and appended to the kernel command
line on the next boot. See
`recipes-omnect/omnect-base-files/omnect-base-files/usr/bin/omnect_extra_bootargs.sh`.

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
