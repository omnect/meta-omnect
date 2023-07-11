# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [kirkstone-next-0.1.11] Q3 2023
  ## [kirkstone-0.19.2] Q3 2023
  ## [kirkstone-0.19.1] Q3 2023

## [kirkstone-next-0.1.10] Q3 2023
- corrected `UBOOT_LOCALVERSION` of rpi4 and tauri-l

## [kirkstone-next-0.1.9] Q3 2023
  ## [kirkstone-0.19.0] Q3 2023
  ## [kirkstone-0.18.31] Q3 2023
  ## [kirkstone-0.18.30] Q3 2023
  ## [kirkstone-0.18.29] Q3 2023

## [kirkstone-next-0.1.8] Q3 2023
- fixed omnect-os-update-image generation for rpi3 and polis images

## [kirkstone-next-0.1.7] Q2 2023
  ## [kirkstone-0.18.28] Q2 2023
  ## [kirkstone-0.18.27] Q2 2023
  ## [kirkstone-0.18.26] Q2 2023
  ## [kirkstone-0.18.25] Q2 2023

## [kirkstone-next-0.1.6] Q2 2023
- u-boot-imx: fix patch file that was broken during last merge

## [kirkstone-next-0.1.5] Q2 2023
  ## [kirkstone-0.18.24] Q2 2023
  ## [kirkstone-0.18.23] Q2 2023
  ## [kirkstone-0.18.22] Q2 2023
  ## [kirkstone-0.18.21] Q2 2023
  ## [kirkstone-0.18.20] Q2 2023
  ## [kirkstone-0.18.19] Q2 2023
  ## [kirkstone-0.18.18] Q2 2023
  ## [kirkstone-0.18.17] Q2 2023
  ## [kirkstone-0.18.16] Q2 2023

## [kirkstone-next-0.1.4] Q2 2023
- fixed bootloader_version file generation. -> must be part of the DEPLOYDIR folder to handle setscene yocto mechanism

## [kirkstone-next-0.1.3] Q2 2023
- fixed do_bootloader_package: add additional u-boot-scr:do_deploy dependency for the task

## [kirkstone-next-0.1.2] Q2 2023
- fixed do_bootloader_package: task shall only run in case the deploy step of u-boot and kernel are finished

## [kirkstone-next-0.1.1] Q2 2023
- fixed bootloader dependency during omnect-os-update-image generation

## [kirkstone-next-0.1.0] Q2 2023
- added handling to update the bootloader via swupdate
  (swupdate has to support the archive feature,
  otherwise the whole update will not work -> breaking change for current release)

## [kirkstone-next-0.0.10] Q2 2023
- swupdate: enabled archive support

## [kirkstone-next-0.0.9] Q2 2023
  ## [kirkstone-0.18.15] Q2 2023
  ## [kirkstone-0.18.14] Q2 2023
  ## [kirkstone-0.18.13] Q2 2023

## [kirkstone-next-0.0.8] Q2 2023
  ## [kirkstone-0.18.12] Q2 2023
  ## [kirkstone-0.18.11] Q2 2023
  ## [kirkstone-0.18.10] Q2 2023
  ## [kirkstone-0.18.9] Q1 2023
  ## [kirkstone-0.18.8] Q1 2023

## [kirkstone-next-0.0.7] Q1 2023
  ## [kirkstone-0.18.7] Q1 2023
  ## [kirkstone-0.18.6] Q1 2023
  ## [kirkstone-0.18.5] Q1 2023
  ## [kirkstone-0.18.4] Q1 2023
  ## [kirkstone-0.18.3] Q1 2023
  ## [kirkstone-0.18.2] Q1 2023
  ## [kirkstone-0.18.1] Q1 2023
  ## [kirkstone-0.18.0] Q1 2023

## [kirkstone-next-0.0.6] Q1 2023
  ## [kirkstone-0.17.6] Q1 2023
  ## [kirkstone-0.17.5] Q1 2023
  ## [kirkstone-0.17.4] Q1 2023
  ## [kirkstone-0.17.3] Q1 2023
  ## [kirkstone-0.17.2] Q1 2023
  ## [kirkstone-0.17.1] Q1 2023
  ## [kirkstone-0.17.0] Q1 2023

## [kirkstone-next-0.0.5] Q1 2023
  ## [kirkstone-0.16.3] Q1 2023

## [kirkstone-next-0.0.4] Q1 2023
  ## [kirkstone-0.16.2] Q1 2023
  ## [kirkstone-0.16.1] Q1 2023

## [kirkstone-next-0.0.3] Q1 2023
  ## [kirkstone-0.16.0] Q1 2023

## [kirkstone-next-0.0.2] Q1 2023
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

## [kirkstone-next-0.0.1] Q1 2023
- azure-osconfig: updated to 1.0.5.2023013001
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
