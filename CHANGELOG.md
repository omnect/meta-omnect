# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [kirkstone-0.28.11] Q1 2024
- omnect-device-service update to 0.14.14:
  - prolonging watchdog timeout while validating firmware update
  - configurable azure-iot-sdk-c do_work frequency via environment variable AZURE_SDK_DO_WORK_FREQUENCY_IN_MS [1..100]

## [kirkstone-0.28.10] Q1 2024
- rpi: prioritize serial console over tty0
  (stdout will bind to serial console instead of tty0 in e.g. initramfs)
- flash-mode-2: fixed typos + added output messages

## [kirkstone-0.28.9] Q1 2024
- distro conf: set `SDK_NAME_PREFIX` and `SDK_VERSION` to get meaningful `TOOLCHAIN_OUTPUTNAME`

## [kirkstone-0.28.8] Q1 2024
- kas:
  - updated bitbake to tag ref yocto-4.0.15
  - updated openebedded-core to tag ref yocto-4.0.15
  - updated meta-openembedded to latest kirkstone HEAD
  - updated meta-swupdate to latest kirkstone HEAD
  - updated meta-virtualization to latest kirkstone HEAD
  - updated meta-phytec to latest kirkstone HEAD
  - updated meta-freescale to latest kirkstone HEAD
  - updated meta-raspberrypi to latest kirkstone HEAD
- u-boot-imx: adapted omnect-env.patch to u-boot-imx 2022.04

## [kirkstone-0.28.7] Q1 2024
- iot-hub-device-update: use /etc/sw-versions file for swupdate_consent_handler
- omnect-device-service: updated to 0.14.12

## [kirkstone-0.28.6] Q4 2023
- cargo_common.bbclass: disabled creating path overrides
  (generated path overrides clashes with rust offline builds,
  so we used an own patch mechanism anyway;
  the current used rust version 1.74.0 warns about altered dependencies by
  path overrides and buggy behavior of the crate graph)
- omnect-device-service: updated to 0.14.11
- iot-client-template-rs: removed

## [kirkstone-0.28.5] Q4 2023
- iot-identity-service: updated to 1.4.7
- iotedge: updated to 1.4.27

## [kirkstone-0.28.4] Q4 2023
- iot-hub-device-update:
  - corrected file permissions on files required by consent handler at build
    time
  - corrected file permissions and ownership on files required by consent
    handler at runtime (tmpfilesd)
    (user/group uuids changed from versions before kirkstone-0.28.0)

## [kirkstone-0.28.3] Q4 2023
- README.md: removed references to poky

## [kirkstone-0.28.2] Q4 2023
- initramfs: output from fsck written to kmsg

## [kirkstone-0.28.1] Q4 2023
- rust: updated to 1.74.0
- wifi-commissioning-gatt-service: updated to 0.3.9
- omnect-device-service: updated to 0.14.9

## [kirkstone-0.28.0] Q4 2023
- distro config based on `nodistro` instead of `poky`
- eg500: configured systemd hardware watchdog
- kas: updated meta-phytec to latest kirkstone HEAD
- u-boot-imx: adapted omnect-env patch to meta-phytec update
- aziot-identity-precondition: handle if 00-super.toml is non-existent or empty

## [kirkstone-0.27.3] Q4 2023
- initramfs:
  - flash-mode-2: fixed filesystem problems of boot partition for u-boot devices
  - welotec eg500: fixed factory-reset mode in case boot partition fsck return an error

## [kirkstone-0.27.2] Q4 2023
- initramfs:
  - added dosfstools for u-boot devices to fix fsck vfat handling
  - added fsck error status to kmsg
  - fixed fsck.json content for u-boot devices

## [kirkstone-0.27.1] Q4 2023
- eg500: wwan interface added to online interface list defined in variable
  OMNECT_WAIT_ONLINE_INTERFACES_BUILD

## [kirkstone-0.27.0] Q4 2023
- added class `dependency-track` to create a sbom with target packages
- removed `ptest` and `gobject-introspection` from DISTRO_FEATURES
- removed `serial` and `qemu-usermode` from MACHINE_FEATURES
- tauri/polis: don't install `imx-m4-demos`
- `do-client`: removed obsolete dependency to `cpprest`
- `dbus`: corrected build dependency `autoconf-archive-native`
- `docker`: removed default dependency to `btrfs-tools`
  (since the recipe disables the graph driver for btrfs anyway)
- removed default dependencies on x86-64: `syslinux`, `systemd-boot`
- corrected `CVE_PRODUCT` entries for usage with class `dependency-track`
  via omnect-os-cve.conf
- corrected `PV`-handling for recipes which only set `git` or `AUTOINC...`
  as `PV` (exception: azure-blob-storage-file-upload-utility, because it
  doesn't have an official release)

## [kirkstone-0.26.0] Q4 2023
- added general cellular support using NetworkManager and ModemManager to control
  mobile interfaces and connections
- enabled cellular support for welotec board Arrakis Mk3 pico
- add information about customization of interfaces to be considered
  for online state detection in README.md

## [kirkstone-0.25.12] Q4 2023
- kas:
  - updated poky to 4.0.14
  - updated meta-openembedded to latest kirkstone HEAD
  - updated meta-swupdate to latest kirkstone HEAD
  - updated meta-virtualization to latest kirkstone HEAD
  - updated meta-phytec to latest kirkstone HEAD
  - updated meta-freescale to latest kirkstone HEAD
  - updated meta-imx to kirkstone-5.15.71-2.2.2
- u-boot-imx: adapted patches to u-boot-imx 2022.04

## [kirkstone-0.25.11] Q4 2023
- added journald logging driver to send container logs to systemd journal

## [kirkstone-0.25.10] Q4 2023
- documentation: restructured readme files and added vendor specific docu

## [kirkstone-0.25.9] Q4 2023
- iot-hub-device-update:
  - added SOFTWARE_VERSION to installed_criteria for user_consent
  - cleaned up user consent information during is_installed step
    to prevent outdated consent information from being reported

## [kirkstone-0.25.8] Q4 2023
- iot-hub-device-update: fixed retry handling for swupdate_handler_v2

## [kirkstone-0.25.7] Q4 2023
- omnect-os-distro.conf: removed `ext2` and `vfat` from `MACHINE_FEATURES` to
  prevent installation of packagegroup-base-ext2 and packagegroup-base-vfat

## [kirkstone-0.25.6] Q4 2023
- omnect-device-service: bumped to 0.14.8 which fixes ssh_tunnel feature and removed ssh_handling feature

## [kirkstone-0.25.5] Q4 2023
- rpi4:
  - set console kernel parameter for tty and ttyS0 for release and devel images
  - disable rpi logo on kernel boot
  - increase u-boot version, because the above changes enforce a bootloader update
- tauril2:
  - set console kernel parameter for ttymxc2 for release and devel images
  - increase u-boot version, because the above change enforces a bootloader update
    of the release image
- distro: corrected kernelparameter loglevel for release image, so we log with
  severity `KERN_CRIT`(2), `KERN_ALERT` (1), `KERN_EMERG` (0)

## [kirkstone-0.25.4] Q4 2023
- flash-mode-2: fixed runtime error

## [kirkstone-0.25.3] Q4 2023
- flash-mode-{2,3}: verify copied wic.xz before flashing
- flash-mode-3: don't verify url certificate if device has no RTC

## [kirkstone-0.25.2] Q4 2023
- initramfs: fsck result hardening; compress fsck output before base64 encoding

## [kirkstone-0.25.1] Q4 2023
- iot-hub-device-update: don't install upstreams adu-swupdate.sh
- u-boot:
  - write `omnect_u-boot_version` as readonly into u-boot default env
  - don't set `omnect_u-boot_version` by `swupdate_handle_v2_u-boot.sh`
    (now we reliably don't flash if the update has `omnect_u-boot_version` as current)
  - omnect_uboot_configure_env.bbclass: fixed a concatination problem of
    `CONFIG_ENV_FLAGS_LIST_STATIC`

## [kirkstone-0.25.0] Q4 2023
- iot-hub-device-update: changed to swupdate-handler-v2

## [kirkstone-0.24.1] Q4 2023
- omnect-device-service: bumped to 0.14.5 which fixes error string in results of direct methods

## [kirkstone-0.24.0] Q4 2023
- bootloader-update (breaking change for current release):
  - introduction of bootloader update for phytec tauril2 ,raspberry pi4 and welotec eg500
  - force first-boot condition when updating bootloader, because we switch root partition without update-validation

## [kirkstone-0.23.3] Q4 2023
- machine config: re-define OMNECT_PART_SIZE_ROOTFS for eg500

## [kirkstone-0.23.2] Q4 2023
- omnect-os-initramfs:
  - flash-mode-1: corrected reformating `etc` and `data`
  - flash-mode-3: escaped url to download

## [kirkstone-0.23.1] Q4 2023
- device-update-agent: fixed user_consent cancel_request workflow

## [kirkstone-0.23.0] Q4 2023
- omnect-os-initramfs:
  - new flash-mode-3
  - flash-mode-1: don't write u-boot env for devices using grub

## [kirkstone-0.22.9] Q4 2023
- omnect-device-service: update to version 0.14.4

## [kirkstone-0.22.8] Q4 2023
- kas:
  - updated poky to 4.0.13
  - updated meta-openembedded to latest kirkstone HEAD
  - updated meta-security to latest kirkstone HEAD
  - updated meta-virtualization to latest kirkstone HEAD
  - updated meta-phytec to latest kirkstone HEAD
  - updated meta-freescale to latest kirkstone HEAD
  - updated meta-raspberrypi to latest kirkstone HEAD
  - removed now obsolete meta-phytec_do_not_overwrite_BBMASK.patch
  - adapted linux-imx_%.bbappend to meta-phytec changes
  - omnect-os-image: install kernel-image explicitly to rootfs
    (meta-phytec removed it from rootfs for phyimx8 devices)

## [kirkstone-0.22.7] Q4 2023
- iot-identity-service: bumped to 1.4.6
- iotedge: bumped to 1.4.21
- do-client: bumped to 1.1.0

## [kirkstone-0.22.6] Q4 2023
- kas: added dev/own_mirror_only.yaml to allow usage of a dedicated mirror only

## [kirkstone-0.22.5] Q3 2023
- omnet-os-distro.conf/machine configs: introduce possibility to define
  different rootfs maximum sizes for release and development images
  Note: currently the sizes are still identical for both image types, only
  distinction upon setting of OMNECT_RELEASE_IMAGE was added

## [kirkstone-0.22.4] Q3 2023
- grub-cfg: deploy grub.cfg to `DEPLOYDIR`

## [kirkstone-0.22.3] Q3 2023
- omnect-os-image: fixed wic image dependency for devices using grub

## [kirkstone-0.22.2] Q3 2023
- welotec eg500: refactored wic image to use the correct grub.cfg;
  NOTE: you have to inject `recipes-omnect/grub-cfg/grub-cfg/grub-usb.cfg`
  into the `boot` partition `/EFI/BOOT/grub.cfg` now, if you want to be able
  to boot from usb.
  (this enables flash-mode-2 to flash the correct grub.cfg independent of the
  used omnect-os-initramfs)

## [kirkstone-0.22.1] Q3 2023
- grub-cfg: append `APPEND` to kernel cmdline

## [kirkstone-0.22.0] Q3 2023
- omnect-os-initramfs:
  - introduced fsck status handling
    (writes fsck error state to /run/omnect-device-service/fsck.json)
  - refactored fsck and reformat handling
  - log with identifier "omnect-os-initramfs"
  - removed `get_block_device`
  - refactored ownership and permissions of /run/omnect-device-service/
- systemd-tmpfilesd: refactored permissions of
  /run/omnect-device-service/ssh_tunnel/

## [kirkstone-0.21.1] Q3 2023
- iot-hub-device-update: fixed CancelApply for swupdate_handler_v1,
  so that the correct revert function is called from the adu-swupdate.sh script

## [kirkstone-0.21.0] Q3 2023
- added bootloader-env recipe: `bootloader_env.sh` as wrapper for
  `fw_{setenv,printenv}` (u-boot) vs `grub-editenv` (grub)
- initramfs flash-mode-2: added workaround for filesystem problems of boot
  partition when kernel and/or initramfs are loaded from boot partition via grub
- README.md: simplified documentation due to introduction of
  `bootloader_env.sh` wrapper
- kernel: generic configuration of `CONFIG_OVERLAY_FS_INDEX` so it is equal
  on all platforms

## [kirkstone-0.20.0] Q3 2023
- omnect-device-service:
  - update to version 0.14.0
  - add ssh_tunnel_user
  - add sudoers entry with ssh command permissions for ssh_tunnel_user
  - add systemd-tmpfiles for omnect-device-service
- sshd: configure to accept certificate-based authentication for ssh-tunnel feature
- iot-hub-device-update: fix path inconsistenies

## [kirkstone-0.19.12] Q3 2023
- linux-welotec eg500: compile network driver into kernel
  (initramfs otherwise would have to load the module for
  flash-mode 2)
- initramfs flash-mode 2:
  - don't use variable OMNECT_ETH0
    (eth names differ between initramfs and booted omnect-os,
    because systemd renames devices)
  - handle efibootmgr entry for efi devices

## [kirkstone-0.19.11] Q3 2023
- kas: adapted to kas 4.0

## [kirkstone-0.19.10] Q3 2023
- kas:
  - updated poky to 4.0.12
  - updated meta-openembedded to latest kirkstone HEAD
  - updated meta-security to latest kirkstone HEAD
  - updated meta-swupdate to latest kirkstone HEAD
  - updated meta-virtualization to latest kirkstone HEAD
  - updated meta-phytec to latest kirkstone HEAD
  - updated meta-freescale to latest kirkstone HEAD
  - updated meta-imx to latest kirkstone HEAD
- rust-llvm: adapted to changes in poky

## [kirkstone-0.19.9] Q3 2023
- omnect-device-service: updated to 0.13.2 (fixed potential deadlock)

## [kirkstone-0.19.8] Q3 2023
 - omnect_get_dps_tpm_enrollment.sh: fixed chicken hen problem, prior the
   endorsement key was only printed if the ek hierarchy persistent handle
   was already initialized by iot-identity-service
 - omnect_get_deviceid.sh: fixed missing runtime dependency toml-cli
 - omnect-base-files: profile.d: for tpm devices set env var `TPM2TOOLS_TCTI`

## [kirkstone-0.19.7] Q3 2023
- omnect-device-service: updated to 0.13.0 (switched to async azure-iot-sdk)
- iot-client-template-rs: updated to 0.5.1 (switched to async azure-iot-sdk)
- iot-identity-service: updated to 1.4.5
- iotedge: updated to 1.4.16
- meta-rust: updated toolchain to 1.65

## [kirkstone-0.19.6] Q3 2023
- kas: updated meta-raspberrypi to latest kirkstone HEAD

## [kirkstone-0.19.5] Q3 2023
- added documentation for the welotec eg500 device
- added documentation how to flash on systems which use grub or uboot as OS bootloader

## [kirkstone-0.19.4] Q3 2023
- procps: moved from `OMNECT_DEV_TOOLS_DEFAULT` to `IMAGE_INSTALL` (reason: iotedge needs "ps -e" option)

## [kirkstone-0.19.3] Q3 2023
- initramfs: fixed race condition in flash-mode-2 causing test
  pipeline to fail with missing file wic.xz

## [kirkstone-0.19.2] Q3 2023
- iot-hub-device-update: corrected du-config.json

## [kirkstone-0.19.1] Q3 2023
- removed DISTRO_CODENAME like "kirkstone" from the VERSION info in /etc/os-release

## [kirkstone-0.19.0] Q3 2023
- added machine config: welotec eg500
- added grub support in initramfs and omnect-device-service

## [kirkstone-0.18.31] Q3 2023
- kas: removed no longer wanted variables OMNECT_TOOLS & OMNECT_DEVEL_TOOLS from omnect-os.yaml
- omnect-os-image:
  - moved packages previously defined in OMNECT_TOOLS_DEFAULT directly into IMAGE_INSTALL
    and removed variable completely
    (definition of tools via kas no longer supported, so no fallback needed anymore)
  - added regression test for packages defined in variable OMNECT_DEVEL_TOOLS which checks
    for presence/absence of tools depending on image type (release/devel)
- omnect-os-distro.conf:
  - renamed variable OMNECT_DEVEL_TOOLS_DEFAULT to OMNECT_DEVEL_TOOLS
  - removed no longer needed variable OMNECT_TOOLS_DEFAULT
- os-release: removed no longer existong variable OMNECT_TOOLS

## [kirkstone-0.18.30] Q3 2023
- kas:
  - updated poky to 4.0.11
  - updated meta-openembedded to latest kirkstone HEAD
  - updated meta-swupdate to latest kirkstone HEAD
  - updated meta-phytec to latest kirkstone HEAD
  - updated meta-freescale to latest kirkstone HEAD
  - updated meta-raspberrypi to latest kirkstone HEAD

## [kirkstone-0.18.29] Q3 2023
- ssh(d): switched from dropbear to openssh (preparation for enabling ssh jump-host feature)
- jq: moved from `OMNECT_DEV_TOOLS_DEFAULT` to `OMNECT_TOOLS_DEFAULT` (reason test dependency)
- e2fsprogs-tune2fs: moved from `OMNECT_DEV_TOOLS_DEFAULT` to `OMNECT_TOOLS_DEFAULT` (reason test dependency)

## [kirkstone-0.18.28] Q2 2023
- fixed inclusion of image tools controlled by variables OMNECT_TOOLS and OMNECT_DEVEL_TOOLS
  (tools defined in OMNECT_DEVEL_TOOLS - either as defined in identically
   named environment variable or tools from OMNECT_DEVEL_TOOLS_DEFAULT as
   fallback - were also part in release images and neither variable was listed
   in os-release)

## [kirkstone-0.18.27] Q2 2023
- factory-reset: fixed bug when restore settings

## [kirkstone-0.18.26] Q2 2023
- systemd-networkd-wait-online.service:
  - enabled configuration of timeout via
    `/etc/omnect/systemd-networkd-wait-online.env` and env var
    `OMNECT_WAIT_ONLINE_TIMEOUT_IN_SECS`
  - set default timeout to 5min
  - reboot on failure
- omnect-device-service.service: updated to 0.11.5 (removed force-reboot
  behavior on start limit)

## [kirkstone-0.18.25] Q2 2023
- changed git uri's from ssh to https for recently open sourced omnect dependencies
- wifi-commissioning-gatt-service: updated to version 0.3.6
- iot-client-template-rs: updated to version 0.4.21
- omnect-device-service: updated to version 0.11.4
- iot-module-template-c: removed

## [kirkstone-0.18.24] Q2 2023
- wifi-commissioning-gatt-service:
  - updated to version 0.3.5 which fixes wifi reconnection issues

## [kirkstone-0.18.23] Q2 2023
- omnect-device-service:
  - updated to 0.11.2 which introduces wifi-commissioning feature reporting

## [kirkstone-0.18.22] Q2 2023
- kas:
  - updated meta-phytec to latest kirkstone HEAD

## [kirkstone-0.18.21] Q2 2023
- omnect-device-service: updated to 0.11.1 which introduces feature toggles

## [kirkstone-0.18.20] Q2 2023
- kas:
  - updated meta-openembedded to latest kirkstone HEAD
  - updated meta-security to latest kirkstone HEAD
  - updated meta-virtualization to latest kirkstone HEAD

## [kirkstone-0.18.19] Q2 2023
- iot-hub-device-update: send sd_notify ready when client is authenticated

## [kirkstone-0.18.18] Q2 2023
- phytec tauri-l-2: corrected/adapted `OMNECT_ETH1` to meta-phytec changes

## [kirkstone-0.18.17] Q2 2023
- release image: disabled serial console

## [kirkstone-0.18.16] Q2 2023
- kas:
  - updated poky to 4.0.10
  - updated meta-openembedded to latest kirkstone HEAD
  - updated meta-swupdate to latest kirkstone HEAD
  - updated meta-virtualization to latest kirkstone HEAD
  - updated meta-phytec to latest kirkstone HEAD
  - updated meta-freescale to latest kirkstone HEAD
  - changed ref to meta-imx to an explicit commit, since upstream moved the tag "rel_imx_5.15.71_2.2.0" in the past

## [kirkstone-0.18.15] Q2 2023
- iot-hub-device-update:
  - return error on failed update validation
  - allow retry triggered by cloud

## [kirkstone-0.18.14] Q2 2023
- updated iot-identity-service to 1.4.4
- updated iotedge to 1.4.10

## [kirkstone-0.18.13] Q2 2023
- ip: changed from busybox to iproute2 binary
  (e.g. enables configuring bitrate of can devices)
- kas:
  - updated meta-phytec to latest kirkstone HEAD (u-boot version bump)
  - updated meta-swupdate to latest kirkstone HEAD
- kernel: enabled vcan, vxcan as modules if MACHINE_FEATURES contains can

## [kirkstone-0.18.12] Q2 2023
- omnect-device-service: updated to 0.10.4
  (timeouthandling for systemd operations in update-validation)

## [kirkstone-0.18.11] Q2 2023
- kas:
  - updated poky to 4.0.9
  - updated meta-openembedded to latest kirkstone HEAD
  - updated meta-virtualization to latest kirkstone HEAD
  - updated meta-phytec to latest kirkstone HEAD
  - updated meta-freescale to latest kirkstone HEAD
  - updated meta-raspberrypi to latest kirkstone HEAD
- azure-iot-sdk-c: updated to LTS_01_2023_Ref02

## [kirkstone-0.18.10] Q2 2023
- kas: updated meta-virtualization to latest kirkstone HEAD

## [kirkstone-0.18.9] Q1 2023
- systemd-journal-flush: fixed corruption of journal on reboot
  (now /var/log is unmounted correctly on reboot)

## [kirkstone-0.18.8] Q1 2023
- omnect-device-service: bumped to 0.10.3 which fixes partial twin handling

## [kirkstone-0.18.7] Q1 2023
- aziot-identityd-precondition:
  - renamed from `iot-identity-service-precondition` to `aziot-identityd-precondition`
  - only start on first boot, update validation or update validation failed
    condition:
    either `/run/omnect-device-service/first_boot` or
    `/run/omnect-device-service/omnect_validate_update` or
    `/run/omnect-device-service/omnect_validate_update_failed` exists
- omnect-first-boot.service:
  - moved as part of `systemd_%.bbappend` recipe to own recipe
    `omnect-first-boot.bb`
  - license is now `MIT | Apache 2.0`
- tpm-udev: license is now `MIT | Apache 2.0`
- u-boot/u-boot-imx: fixed env var `bootpart` handling
  (env vars can not be writable and be part of the default env, the default env
   var overlays the written value. here we booted from the wrong partition after
   a reboot after a successful update validation. from userland you could see
   `bootpart=3`, but u-boot took the default value `bootpart=2`)

## [kirkstone-0.18.6] Q1 2023
- kas:
  - updated poky to 4.0.8
  - updated meta-openembedded to latest kirkstone HEAD
  - updated meta-security to latest kirkstone HEAD
  - updated meta-swupdate to latest kirkstone HEAD
  - updated meta-virtualization to latest kirkstone HEAD
  - updated meta-phytec to latest kirkstone HEAD
  - updated meta-freescale to latest kirkstone HEAD
- u-boot/u-boot-imx: lock env

## [kirkstone-0.18.5] Q1 2023
- updated `omnect-device-service` to 0.10.0
- added `polkit` to `DISTRO_FEATURES`
  (dependency of `omnect-device-service` >= 0.10.0)
- removed user `adu` and user `omnect_device_service` from group `disk`

## [kirkstone-0.18.4] Q1 2023
- iot-hub-device-update: fixed "compatibilityId" in du-config.json

## [kirkstone-0.18.3] Q1 2023
- kernel: added CIFS support to allow taking advantage of Samba/Windows shares
  when wanting to store device data for whatever reason

## [kirkstone-0.18.2] Q1 2023
- iot-hub-device-update: added "compatibilityId" to "additionalDeviceProperties" in du-config.json

## [kirkstone-0.18.1] Q1 2023
- iot-hub-device-update: timer triggers service if it wasn't activated 5mins
  after boot
  (this is meaningful if the service activation is skipped at first start and
  thus the service never had the state "inactive". this can happen in an update
  validation scenario. a successful update validation should trigger the start
  of the service via path activation by deleting the barrier path which caused
  the activation skip in the first place. this additional timer setting is a
  backup, if the path activation after deleting the barrier path fails.)

## [kirkstone-0.18.0] Q1 2023
- uboot (tauri/polis): enabled conditional loading of device tree overlays
  (set e.g. via `fw_setenv overlays imx8mm-phygate-tauri-rs232-rs232.dtbo`)
- README.md: corrected dependencies
- README.device.md:
  - updated BSP features table
  - added device tree overlay documentation

## [kirkstone-0.17.6] Q1 2023
- iptables:
  - switched from legacy to nft variant
  - changed permissions to allow execution by omnect-device-service
- initramfs: refactored omnect-device-service-startup to only create
  conditional temp files, e.g. for update validation
  (static temp files now get created by systemd-tmpfiles.d)
- omnect-device-service: updated to 0.9.0 (enabled ssh handling via direct methods)

## [kirkstone-0.17.5] Q1 2023
- removed azure-osconfig

## [kirkstone-0.17.4] Q1 2023
- initramfs:
  - turn on unlimited kmsg ratelimit when running fsck.ext4
  - fixed typo when printing fsck status

## [kirkstone-0.17.3] Q1 2023
- iot-identity-service:
  - patched aziot-identityd in order to send sd-notify after successful startup
  - dependent services (e.g. iot-hub-device-update, omnect-device-service) are better synchronized now regarding connection setup to azure cloud
- iot-hub-device-update:
  - patched in order to restart in case an unauthenticated:no-network message was received
  - this avoids bugs where reported properties might be empty after iot-identity-service was restarted for some reason

## [kirkstone-0.17.2] Q1 2023
- aziot-identityd: corrected install destination of openssl engine aziot_keys

## [kirkstone-0.17.1] Q1 2023
- initramfs: changed fsck strategy from "-y" to "-p"

## [kirkstone-0.17.0] Q1 2023
- fallback handling for A/B updates
- u-boot: implemented update workflow with fallback handling
- initramfs: u-boot update flag "omnect_validate_update" creates
  /run/omnect-device-service/omnect_validate_update
- omnect-device-service:
  - if module provisioning is successful
    delete /run/omnect-device-service/omnect_validate_update
    and set u-boot env accordingly
  - reboot if service is started ten times in two minutes
- iot-hub-device-update:
  - set u-boot env "omnect_validate_update" handling on apply/revert
  - only start if
    /run/omnect-device-service/omnect_validate_update
    doesn't exist

## [kirkstone-0.16.3] Q1 2023
- omnect-os-image: cleaned up tools to be integrated in development and
  production images

## [kirkstone-0.16.3] Q1 2023
- azure-osconfig: removed
- iot-identity-service:
  - updated version to 1.4.3
  - renamed recipe "iot-identity-service" -> "aziot-identityd"
  - recipe file aziot-identityd_1.4.3.bb was generated by cargo bitbake
  - moved our adaptions of build instructions to aziot-identityd.inc
  - removed openssl 3.x patches
- iotedge:
  - updated version to 1.4.9
  - removed openssl 3.x patches

## [kirkstone-0.16.2] Q1 2023
- iot-hub-device-update: fixed jq call in recipe (do_install:append)

## [kirkstone-0.16.1] Q1 2023
- iot-identity-precondition-service:
  - changed type to "oneshot" to ensure follow up units
    get startet after the process exits and not as soon `execve` is started
  - changed wantedby dependency to basic.target

## [kirkstone-0.16.0] Q1 2023
- dropbear: disabled password login for release builds
- imx-atf: default log level error for release builds
- initramfs:
  - install debug module only for non-release builds
  - write messages and errors to /dev/kmsg
    to respect kernel cmdline arg "quiet" and to push initramfs
    output to the journal
  - bind mount / without overlayfs to /mnt/rootCurrent
  - fixed imx-sdma handling for images where "persistent-var-log" is disabled
  - exit handler starts bash on fail for most initramfs scripts in non-release builds
- omnect-os-image: disabled getty for release builds
- omnect user: enabled sudo without password
- systemd: disabled auto and reserved virtual terminals for release builds
- systemd-serialgetty: disabled for release builds (at buildtime)
- u-boot-imx/phytec: silent console for release builds
- u-boot/rpi: silent console for release builds
- u-boot/kernel: kernel boot is quiet on consoles for release builds

## [kirkstone-0.15.10] Q1 2023
- iot-hub-device-update: updated to 1.0.2

## [kirkstone-0.15.9] Q1 2023
- iot-identity-service/iotedge: don't restart services when calling `config apply`
- iot-identity-service-precondition: start before aziot-tpmd as well

## [kirkstone-0.15.8] Q1 2023
- kas:
  - updated poky to 4.0.7
  - updated meta-openembedded to latest kirkstone HEAD
  - updated meta-swupdate to latest kirkstone HEAD
  - updated meta-virtualization to latest kirkstone HEAD
  - updated meta-phytec to latest kirkstone HEAD
  - updated meta-freescale to latest kirkstone HEAD

## [kirkstone-0.15.7] Q1 2023
- iot-identity-service-precondition: added handling to restart on failure

## [kirkstone-0.15.6] Q1 2023
- iot-identity-service: updated to 1.4.2
- iotedge: updated to 1.4.8

## [kirkstone-0.15.5] Q1 2023
- iot-identity-service-precondition: synchronized startup with iotedge
  (fixes race with aziot-edged reading the configuration via aziot-identityd)

## [kirkstone-0.15.4] Q1 2023
- azure-iot-sdk-c: updated to LTS_01_2023_Ref01

## [kirkstone-0.15.3] Q1 2023
- install omnect_get_dps_tpm_enrollment.sh only if MACHINE_FEATURES includes tpm2

## [kirkstone-0.15.2] Q1 2023
- iot-identity-service-precondition: set service type to "exec"
  (prevents race condition with the system start of aziot-identityd)

## [kirkstone-0.15.1] Q1 2023
- updated iot-hub-device-update to 1.0.1

## [kirkstone-0.15.0] Q1 2023
- initramfs:
  - moved from recipes-core -> recipes-omnect
  - split flash-mode script into explicit flash-mode-1 and flash-mode-2
  - reversed meaning of `flash-mode` `1` resp. `2`
  - flash-mode-1 (installing to other disk) is installed per default
  - flash-mode-2 is installed if `DISTRO_FEATURES` includes `flash-mode-2`
  - flash-mode-1 supports uefi handling
  - both flash-modes support grub
  - added handling of sdX partitions (e.g. os on usb-stick)
  - rootblk-dev
    - additionally creates /dev/omnect/rootCurrent
    - writes initramfs version as banner
  - omnect-os-image: moved from recipes-extended -> recipes-omnect
  - removed sstate handling for initramfs do_image_complete
    (doesn't work anymore because we add os-release to initramfs)
- kas: moved flash-mode -> flash-mode-2
- tpm-udev: moved from recipes-core -> recipes-omnect

## [kirkstone-0.14.4] Q1 2023
- kas:
  - updated poky to 4.0.6
  - updated meta-openembedded to latest kirkstone HEAD
  - updated meta-swupdate to latest kirkstone HEAD
  - updated meta-virtualization to latest kirkstone HEAD
  - updated meta-phytec to latest kirkstone HEAD
  - updated meta-freescale to latest kirkstone HEAD
  - updated meta-imx to rel_imx_5.15.71_2.2.0
- u-boot-imx: adapted enable_boot_script.patch for phytec devices

## [kirkstone-0.14.3] Q1 2023
- omnect-device-service: bumped to 0.6.3
- iot-client-template-rs: bumped to 0.4.12

## [kirkstone-0.14.2] Q1 2023
- do-client/systemd-tmpfiles.d: adapted rule to ensure group do (iot-hub-device-client) can write connection string

## [kirkstone-0.14.1] Q1 2023
- kernel/iptables: added common kernel netfilter configuration fragment
  (fixes iptables restore on tauri)
- added iptables to omnect-os-image (before iptables was only a runtime dependency of docker)

## [kirkstone-0.14.0] Q1 2023
- iptables: added default firewall configuration depending on Developer/Release build
- kas: enabled configuration of a release build (`OMNECT_RELEASE_IMAGE=1`)

## [kirkstone-0.13.11] Q1 2023
- iot-hub-device-update/swupdate: don't handle u-boot bootparam via swupdate

## [kirkstone-0.13.10] Q1 2023
- iot-identity-service: fixed systemd-tmpfiles

## [kirkstone-0.13.9] Q1 2023
- iot-identity-service:
  - fixed systemd-tmpfiles permission handling
  - call iotedge/aziotctl config apply on every boot

## [kirkstone-0.13.8] Q1 2023
- iot-identity-service: fixed systemd-tmpfiles permission handling

## [kirkstone-0.13.7] Q1 2023
- iot-identity-service:
  - refactored systemd-tmpfiles handling
  - fixed systemd-tmpfiles permission handling for /var/lib/aziot/

## [kirkstone-0.13.6] Q4 2022
- removed kas example files
- fixed readme

## [kirkstone-0.13.5] Q4 2022
- iot-identity-service: fixed systemd-tmpfiles permission handling

## [kirkstone-0.13.4] Q4 2022
- iot-identity-service: fixed systemd-tmpfiles permission handling

## [kirkstone-0.13.3] Q4 2022
- removed device enrollment demo with provisioning via tpm
- added tpm handling and tpm2-tools if MACHINE_FEATURES includes tpm
- added script to get registration information from a tpm device

## [kirkstone-0.13.2] Q4 2022
- initramfs flash-mode 2: added gpt partition table support

## [kirkstone-0.13.1] Q4 2022
- initramfs resize-data: use `sgdisk` instead of `parted` to fix gpt partition backup table
  (parted is not really scriptable. it's interactive and behaved differently with different
  flashed images (difference were injected files/certs to different partitions))

## [kirkstone-0.13.0] Q4 2022
- added support for gpt partition layout of rpi4 and tauri-l devices

## [kirkstone-0.12.0] Q4 2022
- enabled `wireguard` kernel module for all devices

## [kirkstone-0.11.13] Q4 2022
- updated iotedge to 1.4.4
- updated iot-identity-service to 1.4.1

## [kirkstone-0.11.12] Q4 2022
- fixed `lshw` segfault on tauri-l devices

## [kirkstone-0.11.11] Q4 2022
- systemd: enabled coredump handling distro-wide
  (we currently use the default settings, which can be adapted or disabled in
  /etc/systemd/coredump.conf)
- docker: enabled bash-completion

## [kirkstone-0.11.10] Q4 2022
- warn if `IMAGE_GEN_DEBUGFS` is `1` and `gdbserver` not part of the image

## [kirkstone-0.11.9] Q4 2022
- fixed possible omnect-first-boot deadlock

## [kirkstone-0.11.8] Q4 2022
- phytec polis: fixed imx-gpu-viv build
- imx-boot-phytec: search path fix independent of meta-omnect path

## [kirkstone-0.11.7] Q4 2022
- fixed incorrect permissions for /etc/adu (expected: 0750)

## [kirkstone-0.11.6] Q4 2022
- updated deviceupdate-agent to 1.0.0
- updated do-client/do-client-sdk to 1.0.0
- renamed meta-ics-dm to meta-omnect in osconfig

## [kirkstone-0.11.5] Q4 2022
- kernel: linux-imx is now 5.15.52
- kas:
  - updated meta-imx to nxp release rel_imx_5.15.52_2.1.0 (kirkstone)
  - updated meta-phytec to latest HEAD
  - updated meta-freescale to latest HEAD
  - introduced meta-freescale-distro (dependency of meta-imx)
- README: fixed Versioning chapter

## [kirkstone-0.11.4] Q4 2022
- fixed rpi kernel build
- kas:
  - patched meta-virtualization layer.conf to get the location of its layerdir
  - deleted unused meta-rust related patch

## [kirkstone-0.11.3] Q4 2022
- fixed rpi kernel (rpi kernel was missing overlayfs)

## [kirkstone-0.11.2] Q4 2022
- distro conf:
  - added generic lxc + docker kernel config for iot and iotedge image
  - disabled kvm kernel support (was set in linux-imx kernel)
- kas:
  - updated meta-openembedded to latest HEAD
  - updated meta-swupdate to latest HEAD
  - updated meta-virtualization to latest HEAD
  - updated poky to 4.0.5
  - meta-virtualization is now part of the distro kas config
    (means we also include the layer when building iot images)
- fixed omnect_first_boot.sh when using devel images without tpm enrollment
  config
- moved omnect-base-files to recipes-omnect
- fixed random azure-osconfig build runtime error
- phytec devices: load imx_sdma in initramfs to prevent race conditions with
  drivers using sdma

## [kirkstone-0.11.1] Q4 2022
- fixed busybox build

## [kirkstone-0.11.0] Q4 2022
- introduced azure-osconfig (https://github.com/Azure/azure-osconfig)
- disabled syslog/klog in busybox (os-config complained and we don't use it anyway)
- added var `IMAGE_INSTALL` to /etc/os-release (for smoke-test)

## [kirkstone-0.10.1] Q4 2022
- wifi-commissioning-gatt-service: updated to version 0.3.0

## [kirkstone-0.10.0] Q4 2022
- renamed to omnect:
  - renamed all occurrences of ics in files
  - renamed all occurrences of ics in filenames

## [kirkstone-0.9.4] Q4 2022
- renamed meta-ics-dm to meta-omnect

## [kirkstone-0.9.3] Q4 2022
- renamed to omnect:
  - renamed module icsdm-device-service to omnect-device-service
  - renamed user and group icsdm-device-service to omnect-device-service
  - renamed /etc/ics_dm to /etc/omnect
  - renamed /dev/ics_dm to /dev/omnect

## [kirkstone-0.9.2] Q4 2022
- renamed distro from ICS-DM-OS to omnect

## [kirkstone-0.9.1] Q4 2022
- iotedge:
  - updated to 1.4.2
  - renamed recipe iotedge-cli to iotedge
  - renamed recipe iotedge-daemon to aziot-edged

## [kirkstone-0.9.0] Q4 2022
- phygate-tauri-l, phyboard-polis: enabled hardware watchdog

## [kirkstone-0.8.4] Q4 2022
- phytec u-boot: provide bootcmd_pxe

## [kirkstone-0.8.3] Q4 2022
- systemd: enabled bash-completion

## [kirkstone-0.8.2] Q4 2022
- fixed icsdm-device-service and iot-client-template build

## [kirkstone-0.8.1] Q4 2022
- renamed from ICS-DeviceManagement to omnect github orga

## [kirkstone-0.8.0] Q4 2022
- added flash mode 2, see README.md for further information

## [kirkstone-0.7.5] Q4 2022
- kas:
  - switched meta-imx url to nxp default repository
  - updated meta-openembedded to latest kirkstone head
  - updated meta-swupdate to latest kirkstone head

## [kirkstone-0.7.4] Q3 2022
- initramfs: fixed kernel panic in resize data

## [kirkstone-0.7.3] Q3 2022
- do-client: fixed systemd-tmpfiles permission handling for /etc/deliveryoptimization-agent

## [kirkstone-0.7.2] Q3 2022
- do-client: fixed systemd-tmpfiles permission handling for /var/log/deliveryoptimization-agent
  (reverts kirkstone-0.7.1)

## [kirkstone-0.7.1] Q3 2022
- iot-hub-device-update: fixed systemd-tmpfiles permission handling for /var/log/deliveryoptimization-agent

## [kirkstone-0.7.0] Q3 2022
- added pxe boot support for phytec boards

## [kirkstone-0.6.2] Q3 2022
- iot-hub-device-update: explicitly create /var/lib/adu/downloads via systemd-tmpfiles

## [kirkstone-0.6.1] Q3 2022
- iot-hub-device-update: fixed systemd-tmpfiles permission handling

## [kirkstone-0.6.0] Q3 2022
- demo-portal-module:
  - renamed to icsdm-device-service
  - added direct method "reboot"
  - merged existing demo-portal and factory_reset user to icsdm_device_service user
  - kas: moved from example to default feature
- iot-client-template-rs: bumped to 0.4.9
- factory-reset: fixed bug when setting reset type '0'

## [kirkstone-0.5.7] Q3 2022
- kas:
  - updated poky to 4.0.4
  - updated to latest meta-openembedded
  - updated to latest meta-virtualization
  - updated to latest meta-phytec

## [kirkstone-0.5.6] Q3 2022
- azure-iot-sdk-c: updated to LTS_07_2022_Ref02

## [kirkstone-0.5.5] Q3 2022
- initramfs: explicitly sync before reboot in flash-mode

## [kirkstone-0.5.4] Q3 2022
- set static uid/gid 15581 for user ics-dm

## [kirkstone-0.5.3] Q3 2022
- iot-identity-service: revert kirkstone-0.5.2 (it's not recommended to synchronize with
  systemd-udev-settle and it didn't help anyway)

## [kirkstone-0.5.2] Q3 2022
- iot-identity-service: fixed race condition between tpm udev rule and `aziot-tpmd`

## [kirkstone-0.5.1] Q3 2022
- rpi:
  - fixed kernel cmdline and removed default "root" device entry set from meta-raspberrypi
  - removed uneffective statement to set the default cmdline

## [kirkstone-0.5.0] Q3 2022
- phytec imx8mm: added reset cause in u-boot-imx

## [kirkstone-0.4.13] Q3 2022
- iot-identity-service: fixed race condition between `dev-tpmrm0.device` and `aziot-tpmd`
- wifi-commissioning-gatt-service:
  - updated to version 0.2.6
  - added user `wifi-commissioning-gatt` which executes the service
  - restart rpi bluetooth on wifi-commissioning-gatt-service restarts
  (fixes systemd warning: "Special user nobody configured, this is not safe!")

## [kirkstone-0.4.12] Q3 2022
- don't install kernel twice into rootfs
- initramfs:
  - added debug messages in `rootblk_dev` and when getting u-boot env vars
    (can be enabled via bootparam `debug`)
  - enabled detailed debugging via bootparam `shell-debug`
  - fixed rootblk-dev handling (disk by label detection was not save when there are
    equal partition names on different devices)
  - removed udev handling
- u-boot-scr.bbclass: provide root device dependent on used sdcard/emmc device

## [kirkstone-0.4.11] Q3 2022
- demo-portal-module: bumped to 0.5.10
- iot-client-template-rs: bumped to 0.4.8
- kas: updated to latest meta-raspberrypi

## [kirkstone-0.4.10] Q3 2022
- iot-identity-service: start aziot-{certd,identityd,keyd} after time-sync.target

## [kirkstone-0.4.9] Q3 2022
- ics-dm-first-boot: wait until systemd state time-sync reached

## [kirkstone-0.4.8] Q3 2022
- fixed compiling iot-identity-service on rpi3

## [kirkstone-0.4.7] Q3 2022
- phygate tauri-l: fixed systemd-networkd-wait-online.service

## [kirkstone-0.4.6] Q3 2022
- fix build error in release "kirkstone-0.4.5"

## [kirkstone-0.4.5] Q3 2022
- demo-portal-module: bumped to 0.5.9
- iot-client-template-rs: bumped to 0.4.7

## [kirkstone-0.4.4] Q3 2022
- run ics-dm-first-boot.service before first-boot-complete.target

## [kirkstone-0.4.3] Q3 2022
- renamed, for better usability:
  - feature, u-boot environment variable: initramfs-flash-mode -> flash-mode
  - initramfs: wic-image.fifo.xz -> wic.xz
  - initramfs: wic-image.bmap -> wic.bmap

## [kirkstone-0.4.2] Q3 2022
- iot-identity-service: fixed default auth_key_index handling in aziot-tpmd

## [kirkstone-0.4.1] Q3 2022
- iot-identity-service:
  - fixed aziot-tpmd dps key handling
  - build with tpm2-tss package from meta-security instead in context of iot-identity-service

## [kirkstone-0.4.0] Q3 2022
- kas: removed dependency to meta-rust
- added rust 1.62.1
- iot-identity-service/iotedge: updated to 1.4.0

## [kirkstone-0.3.17] Q3 2022
- phygate tauri-l: removed unsupported features from `DISTRO_FEATURES`
- os-release: add `MACHINE` to `/etc/os-release`

## [kirkstone-0.3.16] Q3 2022
- phygate tauri-l: removed features from `MACHINE_FEATURES` the hardware doesn't provide per se
- systemd-networkd-wait-online.service: only add interface `ICS_DM_WLAN0` if
  `MACHINE_FEATURES` includes `wifi`

## [kirkstone-0.3.15] Q3 2022
- iot-client-template-rs, demo-portal-module, iot-module-template-c:
  - start service after time-sync target to avoid time jumps during service start

## [kirkstone-0.3.14] Q3 2022
- `iot-identity-service/iotedge`: fixed provisioning of modules using request content-type different than 'application\json'

## [kirkstone-0.3.13] Q3 2022
- updated `azure-iot-sdk-c` to LTS_07_2022_Ref01
- updated `enrollment` to 0.8.3

## [kirkstone-0.3.12] Q3 2022
- reworked static linking of overlayfs to linux kernel, instead of using loadable module:
  - made kernel config fragment enable-overlayfs.cfg independent from BSP layer
- enforced kmod over busbox kernel module utilities

## [kirkstone-0.3.11] Q3 2022
- kas:
  - updated poky to 4.0.3
  - updated to latest meta-openembedded
  - updated to latest meta-swupdate
  - updated to latest meta-virtualization
- azure-iot-c-sdk,iot-identity-service: adapted openssl patches to openssl 3.0.5

## [kirkstone-0.3.10] Q3 2022
- always link overlayfs to linux kernel, instead of using loadable module:
  - static linking of overlayfs is enforced by the (optional) layer meta-virtualization
  - handle linking method in the same way, independent from the presence of meta-virtualization

## [kirkstone-0.3.9] Q3 2022
- kas:
  - updated to latest meta-freescale
  - updated to latest meta-phytec
- libubootenv: removed unused patch

## [kirkstone-0.3.8] Q3 2022
- demo-portal-module version bump to 0.5.6 and iot-client-template-rs version bump to 0.4.4:
  - fixed panic when closing message channel

## [kirkstone-0.3.7] Q3 2022
- removed `ics-dm-os` test artefact recipes

## [kirkstone-0.3.6] Q3 2022
- demo-portal-module version bump to 0.5.5 and iot-client-template-rs version bump to 0.4.3
  - fixed panic when calling IotHubClient::from_identity_service
  - fixed terminating on ExpiredSasToken
  - updated to latest azure-iot-sdk-sys path variables

## [kirkstone-0.3.5] Q3 2022
- adapted `test-uboot-scr` to new tftpd infrastructure
- fixed `swupdate` bberror handling in .bbappend

## [kirkstone-0.3.4] Q3 2022
- kas:
  - updated to latest meta-freescale
  - updated to latest meta-openembedded
  - updated to latest meta-virtualization

## [kirkstone-0.3.3] Q3 2022
- demo-portal-module: version bump to 0.5.4
- iot-client-template-rs: version bump to 0.4.2
- do-client/do-client-sdk: removed unused 'features_check'

## [kirkstone-0.3.2] Q3 2022
- fixed demo-portal-module bug when fetching source

## [kirkstone-0.3.1] Q3 2022
- merged changes from dunfell: dunfell-1.5.3 - dunfell-1.6.0
- fixed iot-client-template-rs bug when fetching source

## [kirkstone-0.3.0] Q3 2022
- kas:
  - updated poky to 4.0.2
  - updated to latest meta-swupdate
  - updated to latest meta-virtualization
  - updated to latest meta-phytec
  - added meta-imx layer for phytec bsp support
  - fixed `phytec polis` kirkstone integration
  - added `phytec tauri l` support

## [kirkstone-0.2.3] Q3 2022
- merged changes from dunfell: dunfell-1.5.1 - dunfell-1.5.2

## [kirkstone-0.2.2] Q3 2022
- fixed error fetching `iot-module-template-c`

## [kirkstone-0.2.1] Q3 2022
- fixed error fetching `libeis_utils`

## [kirkstone-0.2.0] Q3 2022
- merged changes from dunfell: dunfell-1.3.8 - dunfell-1.5.0
- enabled compatibility with meta-rust (iot-identity-service
  and iotedge 1.3.0 depend on rust 1.61.0)
- updated meta-phytec and meta-freescale to a kirkstone revision
- fixed iot-identity-service and iotedge 1.3.0 build against openssl 3.0.3
- reenabled iotedge in image and enrollment

## [kirkstone-0.1.1] Q2 2022
- merged changes from dunfell: #97, #98 and #99

## [kirkstone-0.1.0] Q2 2022
- initial version supporting yocto kirkstone
- builds supported:
  - iot, tpm-enrollment, rpi4
  - iot, demo-portal, rpi4
- builds not yet supported:
  - all iotedge
  - non rpi4
- limitations:
  - the iot-identity-service is not yet running on the rpi4 target, because of the openssl version 3.0.X,
    which requires major adaptations
  - iotedge images are not yet supported, in general
