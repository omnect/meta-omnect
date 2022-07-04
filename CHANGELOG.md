# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [dunfell-1.5.0] Q3 2022
- iotedge + iot-identity-service: update to stable 1.3.0 (breaking changes in cert renewal)
- iot-identity-service: refactored to use vendored cargo packages, so we're able to mirror
  the corresponding cargo package sources and reproduce our builds
- distro.conf: global setting `RUST_PANIC_STRATEGY = "abort"` to compile iotedge 1.3.0
- kas: changed meta-rust dependency to fork with rust 1.61.0
- rust/bindgen: update to 0.60.1
- rust/cbindgen: update to 0.24.3
- demo-portal-module: removed edition patching
- iot-client-template-rs: removed edition patching
- wifi-commissioning-gatt-server: update to 0.2.3

## [dunfell-1.4.1] Q3 2022
- updated `iot-hub-device-update` to 0.8.2

## [dunfell-1.4.0] Q3 2022
- add feature "panic on OOM"

## [dunfell-1.3.9] Q2 2022
- test_boot.scr: fix for board rev 0xC03111 (was broken by kernel cmdline refactoring)

## [dunfell-1.3.8] Q2 2022
- wifi-comminssioning-gatt-service: fix startup behavior

## [dunfell-1.3.7] Q2 2022
- phytec: u-boot enable_boot_script.patch fix

## [dunfell-1.3.6] Q2 2022
- iotedge: version bump to 1.2.10

## [dunfell-1.3.5] Q2 2022
- poky: update to 3.1.17
- meta-openembedded, meta-swupdate, meta-phytec, meta-freescale: update to latest dunfell head
- Readme: added `scp` usage for new openssh clients (>=9.0)

## [dunfell-1.3.4] Q2 2022
- make the hardware watchdog configuration specific for the raspberrypi platform, because the deadline
  depends on the hardware capabilities

## [dunfell-1.3.3] Q2 2022
- fixed warning: "Syntax for sha256 changed..."

## [dunfell-1.3.2] Q2 2022
- update to `iot-client-template-rs` 0.3.0
- update to `demo-portal-module` 0.5.1
- added --locked to cargo build for wifi-commissioning-gatt-service

## [dunfell-1.3.1] Q2 2022
- update to `iot-hub-device-update` 0.8.1

## [dunfell-1.3.0] Q2 2022
- add factory reset restore list
- demo-portal-module: version bump to 0.5.0
- update user consent handling for iot-hub-device-update:
  - change user_consent_request in request_consent.json to json array type
  - clean user_consent_request info after succeeded user consent

## [dunfell-1.2.0] Q2 2022
- kas:
  - meta-openembedded: updated to latest HEAD of dunfell
  - meta-swupdate: updated to latest HEAD of dunfell
  - poky: updated to 3.1.16
  - meta-virtualization: updated to latest HEAD of dunfell
- enrollment: updated to 0.8.0 (allows setting `DEVICE_ID` or
  `DEVICE_ID_PREFIX` via environment file, e.g. via inject)

## [dunfell-1.1.0] Q2 2022
- add user consent handling for iot-hub-device-update
- demo-portal-module: version bump to 0.4.1

## [dunfell-1.0.1] Q2 2022
- fix ICS_DM_DEVEL_TOOLS_DEFAULT: add jq command-line JSON processor, needed for base test

## [dunfell-1.0.0] Q2 2022
- new versioning scheme for CHANGELOG.md:
  - switch to yoctoversion-major.minor.patch
- add to /etc/os-release:
  - MACHINE_FEATURES
  - meta-ics-dm version, revision and branch
  - ics-dm-os version, revision and branch

## [> 3.1.15.31509222] Q2 2022
- add jq command-line JSON processor, needed for base test

## [> 3.1.15.31258601] Q2 2022
- install systemd aziot-tpmd service and socket only if tpm2 is part of MACHINE_FEATURES,
  in order to prevent useless log entries like 'could not initialize TPM' flooding the log
  and stressing the flash memory, in case of TPM not to be used or present and persistent log feature.

## [> 3.1.15.31043252] Q2 2022
- enable, configure hardware watchdog for raspberrypi platform

## [> 3.1.15.26343127] Q2 2022
- iotedge: version bump to 1.2.9

## [> 3.1.15.26095706] Q2 2022
- iot-client-template-rs:
  - version bump to 0.2.4
  - replacement of patch by do_configure:append for fixing paths and edition in Cargo.toml files

## [>= 3.1.15.x] Q1 2022
- kas:
  - poky: version bump to 3.1.15
  - open-embedded: version bump
  - meta-swupdate: version bump
  - meta-virtualization: version bump
  - removed distro/oe.yaml
- bash/profile: set default `PROMPT_COMMAND` and own default `PS1`

## [> 3.1.14.24302255] Q1 2022
- iot-identity-service: version bump to 1.2.6
- iotedge: version bump to 1.2.8

## [> 3.1.14.23418869] Q1 2022
- use 0.7.2 enrollment

## [> 3.1.14.21880135] Q1 2022
- replace layer-specific kernel command line options by u-boot environment variables

## [> 3.1.14.21851669] Q1 2022
- enrollment:
  - don't require `MACHINE_FEATURES` to include `tpm2`
  - version bump to 0.7.1

## [> 3.1.14.19905831] Q1 2022
- iot-hub-device-update:
  - register step:1, script:1 and update-manifest:4 handler at runtime
  - removed registering of update-manifest (legacy) handler

## [> 3.1.14.19703570] Q1 2022
- add demo-portal-module 0.1.1

## [> 3.1.14.19444061] Q1 2022
- enforce identical busybox configuration for iot and iotedge

## [> 3.1.14.18644632] Q1 2022
- enrollment:
  - set cmake flag `TPM` only if `MACHINE_FEATURES` includes `tpm2`
  - version bump to 0.7.0

## [> 3.1.14.18276533] Q1 2022
- fix setup of factory reset trigger file in case of iot

## [> 3.1.14.17487662] Q1 2022
- iot-module-template-rs 0.2.2: version bump and renaming to iot-client-template-rs 0.2.3

## [> 3.1.14.16646426] Q1 2022
- adaptations for changed yocto overrides syntax

## [>= 3.1.14.x] Q1 2022
- kas:
  - poky: version bump to 3.1.14
  - meta-openembedded: update to latest head of dunfell branch
  - meta-swupdate: update to latest head of dunfell branch
- iot-module-template-rs: version bump to 0.2.2
- iot-identity-service: version bump to 1.2.5
- iotedge: version bump to 1.2.7

## [> 3.1.13.16477381] Q1 2022
- initramfs: create systemd trigger file for factory reset

## [> 3.1.13.16230425] Q1 2022
- factory reset: add support for wipe modes

## [> 3.1.13.16198777] Q1 2022
- `wifi-commissioning-gatt-service`:
  - version bump to 0.2.0
  - switch systemd service type to `notify`

## [> 3.1.13.16182168] Q1 2022
- `iot-module-template-rs` version bump to 0.2.1

## [> 3.1.13.15533182] Q1 2022
- imx-boot-phytec: documented source of files
- kas:
  - consolidated kas/feature/ics-dm-common.yaml -> kas/distro/ics-dm-os.yaml
  - moved kas/feature/ics-dm-demo.yaml -> kas/example/enrollment.yaml
  - kas/feature/iotedge.yaml doesn't implicitly include kas/feature/iot.yaml
    anymore
  - split kas/feature/iot.yaml -> kas/example/{iot-module-template-c,iot-module-template-rs}.yaml
  - moved kas/feature/wifi-commissioning.yaml -> kas/example/wifi-commissioning.yaml
- removed DISTRO_FEATURE `tpm`; we use poky's MACHINE_FEATURE `tpm2` instead
- renamed DISTRO_FEATURE `ics-dm-demo` -> `enrollment`
- enrollment: removed PACKAGECONFIG `tpm` switch; set
  REQUIRED_MACHINE_FEATURES="tpm2"
- iotedge-cli: overwrite LICENSE and LIC_FILES_CHKSUM from cargo-bitbake
  generated recipe
- iotedge-daemon:
  - removed PACKAGECONFIG `ics-dm-demo`
  - overwrite LICENSE and LIC_FILES_CHKSUM from cargo-bitbake generated recipe
- swupdate: consolidated adu-key-pub.bb
- iot-module-template-rs:
  - overwrite LICENSE and LIC_FILES_CHKSUM from cargo-bitbake generated recipe
  - version bump to 0.2.0
- wifi-commissioning-gatt-service:
  - overwrite LICENSE and LIC_FILES_CHKSUM from cargo-bitbake generated recipe
  - version bump to 0.1.5
- moved iot-module-template -> iot-module-template-c

## [> 3.1.13.15239607] Q1 2022
- `iot-hub-device-update`:
  - version bump to 0.8.0
  - added sd_notify.patch (this fixes false successful runs of the smoke-test)
- added `azure-sdk-for-cpp` (dependency of `iot-hub-device-update` >= 0.8.0)
- added `azure-blob-storage-file-upload-utility`
  (dependency of `iot-hub-device-update` >= 0.8.0)
- `do-client` version bump to 0.8.2

## [> 3.1.13.15086663] Q1 2022
- initramfs: rework filesystem mount, mount options and filesystem check

## [> 3.1.13.14709522] Q1 2022
- ics-dm-os-initramfs-test: added missing initramfs scripts

## [> 3.1.13.14704614] Q1 2022
- test-u-boot-scr: fixed setting `bootargs_append` for rpi4 v1.1, if the device
  is completely flashed (u-boot env is erased) and then rebooted

## [> 3.1.13.14434558] Q1 2022
- azure-iot-c-sdk: updated to `LTS_01_2022_Ref01`

## [> 3.1.13.14175483] Q1 2022
- iot-hub-device-update: fixed start up (fixes changes from PR#52)
- iot-identity-service: creation of link `/var/secrets` at buildtime and directory
  `/mnt/data/var/secrets/` at runtime (fixes changes from PR#52)
- os-release: added vars `ICS_DM_DEVEL_TOOLS` and `ICS_DM_DEVEL_TOOLS_DEFAULT`
- ics-dm-first-boot: set `RemainAfterExit=true` to enable testing via
  `systemctl is-active ics-dm-first-boot`
- enrollment: version bump to 0.6.1
- moved recipes-ics-dm-demo/* -> recipes-ics-dm
- moved recipes-ics-dm/ics-dm-iot-module-rs/ recipes-ics-dm/iot-module-template-rs

## [> 3.1.13.13589229] Q1 2022
- add factory reset, which can be triggered by setting the u-boot environment variable `factory-reset`

## [> 3.1.13.13333545] Q1 2022
- swupdate: Don't start swupdate.service. We don't use it and it failed to
  start, which resulted in a degraded status of `systemctl is-system-running`.
- initramfs: Only install `RESIZE_DATA_PACKAGES` if DISTRO_FEATURE `resize-data`
  is set.
- kas: `ICS_DM_PART_SIZE_*` parameters are now configurable via kas. (E.g. the same
  cicd parameter can now be used in build and tests.)

## [> 3.1.13.12869352] Q1 2022

- u-boot: Fixed POR detection for rpi4 board revision 0xC03111 (Raspberry Pi 4 Model B Rev 1.1)
  when using 'test-boot.scr'. This workaround disables the uhc mode of the sdcard.
  So reading/writing times are expected to be slower then usual.

## [>= 3.1.13.x] Q1 2022

- kas: poky update to dunfell 3.1.13
- kas: meta-openembedded update to latest dunfell HEAD ab9fca485e13f6f2f9761e1d2810f87c2e4f060a
- kas: meta-swupdate update to latest dunfell HEAD d018267c3baf826dfc9b2b7307b4f6183353eed1
- kas: meta-virtualization update to latest dunfell HEAD c4f156fa93b37b2428e09ae22dbd7f5875606f4d

## [> 3.1.12.12622913] Q1 2022

- iot-identity-service: update to rev 20d1990858ceb976e8885e0da92f0f9d600b0eb5
  to fix communication problems with libest est-server in version 1.2.4

## [> 3.1.12.12479852] Q1 2022
- remove /etc/ics_dm/enrolled dependency from all aziot service files
- remove first boot handling from factory partition
- add handling to perform a identity config depending on ics-dm-demo and device variant
- add systemd-analyze to target development tools

## [> 3.1.12.12381645] Q1 2022
- support phytec polis device (bt, wifi, partition scheme, adu)
- iot-identity-service: fix deadlock for raspberrypi3 sstate mirror cache
  (if we include GITREV in PV the sstate filename gets to long on
  cortexa7t2hf-neon-vfpv4-icsdm-linux-gnueabi systems)
- initramfs: generate /dev/ics_dm/rootblk device and partition links from boot
  device (this can be referenced independent of the boot device where a static
  configuration of the boot device is necessary)
- swupdate: generic sw-description which unified /dev/ics_dm/rootblk device
- ics_dm_fw_env_config.bbclass: generate fw_env.config with generic
  /dev/ics_dm/rootblk device
- wic: refactored wic file(s) to include a common ics-dm-os.common.wks.inc
- ics-dm-os-image: ICS_DM_DEVEL_TOOLS_DEFAULT: add 'screen' + moved none devel
  tools to IMAGE_INSTALL
- distro conf: set 'resize-data' in DISTRO_FEATURES for all machines + only set
  ICS_DM_PART_OFFSET_UBOOT_ENV* if not already set by machine conf
- added README.device.md
- systemd: fix systemd-networkd-wait-online.service to wait only for at least
  one device to be online either eth0 or wlan0
- iot-identity-service: fix permission problem; enable identity service to
  create cert "device-id" (e.g. for x509 dps provisioning)

## [> 3.1.12.11094660] Q1 2022
- changes for test environment

## [> 3.1.12.5919851] Q1 2022
- add systemd start limit and restart handling for adu-agent, iot-module-template and ics-dm-iot-module-rs
  using systemd timer
- update iot-module-template to 0.2.2
- update ics-dm-iot-module-template-rs to 0.1.3

## [> 3.1.12.5331319] Q4 2021
- fix compiling ics-dm-iot-module-rs for rpi3

## [> 3.1.12.5285946] Q4 2021
- iot-identity-service: only start if config.toml and 00-super.toml exists
- iotedge: only start if config.toml and 00-super.toml exists
- add ics-dm-iot-module-rs 0.1.0
- update enrollment to 0.6.0
- update iot-module-template to 0.2.1

## [> 3.1.12.5165139] Q4 2021
- Add rstinfo u-boot command used to check for power-on reset
- Add build of test boot.scr

## [> 3.1.12.5065554] Q4 2021
- fix wifi-gatt-commissioning authentication

## [> 3.1.12.5047816] Q4 2021
- Add test initramfs, used to flash test images
- Add ethernet support in u-boot for rpi4 genet controller
- Fix inappropriate fifo truncate in dropbear scp daemon

## [> 3.1.12.4743159] Q4 2021
- wifi-commissioning-gatt-service: fix reading device_id from config.toml

## [>= 3.1.12.x] Q4 2021
- kas: poky update to dunfell 3.1.12
- kas: meta-openembedded update to latest dunfell HEAD 7889158dcd187546fc5e99fd81d0779cad3e8d17
- kas: meta-swupdate update to latest dunfell HEAD dcf6616ff28fc8dbc781debf7e9ef44d028421fd
- kas: meta-virtualization update to latest dunfell HEAD 180241e0eee718fc52c7b6b25dbd1d845a8047c4
- restructure kas repository layers to be able to simply cache them in cicd
- remove odroid c2 support
- kas: fix warning regarding adressing includes
- iot-identity-service: change permissions on config.toml, so wifi-commissioning-gatt
  can read device-id

## [> 3.1.11.3789986] Q4 2021
- set permissions on adu-conf.txt, config.toml, enrollment_static.json and its basedirs via
  systemd-tmpfiles.d
- ics-dm_first-boot: append ics-dm-first-boot.sh from factory partition if existing
- initramfs: mount cert and factory partition; if etc partition is empty try
  to copy etc dir from factory partition
- iot-identity-service: only start if /etc/aziot/config.toml exists
- update-ca-certificates: use /mnt/cert/ca as input dir for local ca certificates

## [> 3.1.11.3553861] Q4 2021
- provide initramfs-flash-mode feature

## [> 3.1.11.3447186] Q4 2021
- reenable overwriting src_uri of enrollment and iot-module-template

## [> 3.1.11.3165078] Q4 2021
- iotedge: update to 1.2.6
- iot-identity-service: update to 1.2.4
- fix overlay mount for systems where overlay kernel-module has to be loaded,
  e.g. raspberrypi3

## [> 3.1.11.3133905] Q4 2021
- fix rpi build issue introduced by https://github.com/RPi-Distro/firmware-nonfree/issues/20

## [> 3.1.11.2837673] Q4 2021
- provide persistent var-log feature

## [> 3.1.11.2827980] Q4 2021
- use hardcoded reference for enrollment (0.4.0) and iot-module-template (0.2.0)

## [> 3.1.11.2342287] Q4 2021
- add redundant u-boot environment

## [> 3.1.11.1407973] Q4 2021
- distro.conf: remove tune of IMAGE_OVERHEAD_FACTOR

## [> 3.1.11.537558] Q4 2021
- update partition schema
- add development tools: valgrind, ltrace, strace, gdbserver, htop, lsof, curl, tcpdump, ethtool, lshw, sysstat, ldd, parted, smartmontools, mmc-utils, sudo, ps, dd
- add ics-dm user
- disable direct root login (concerns SSH, serial console and graphical console)
- allow login using ics-dm user; subsequent sudo possible

## [> 3.1.11.531910] Q4 2021
- unbundle initramfs from kernel to speed up build times from sstate cache
  (before the kernel and modules got build every time when building with
  sstate cache)
- add ics-dm-os-initramfs to sstate cache

## [> 3.1.11.1102] Q4 2021
- enrollment: install new enrollment-patch-config-toml@.service

## [> 3.1.11.1073] Q4 2021
- u-boot boot.scr: only use saveenv on first boot to minimize flash wear out
  and robustness against power loss at boot
- u-boot raspberry-pi: patch u-boot to get ftd_addr from firmware and not
  from env; without this patch you can not boot with hdmi connected when
  first boot was without hdmi (or not boot without hdmi when hdmi was
  connected on first boot)
- u-boot-scr-bbclass: enable dynamic bootmedium

## [> 3.1.11.1050] Q4 2021
- update meta-openembedded to latest dunfell head
- update meta-rust to latest master head to include rust-1.54.0
- update meta-swupdate to latest dunfell head
- update meta-virtualization to latest dunfell head
- update meta-raspberrypi to latest dunfell head
- iotedge-cli,iotedge-daemon:
  ignore all instances of #[warn], #[deny], and #[forbid] lint directives
  otherwise edgelet-docker will fail with rust 1.54 caused by #[deny(rust_2018_idioms)]
- delete fstab: prevent rw remount of "/"
- initramfs: mount /boot and tmpfs
- wifi-commissioning-gatt-service: update to 0.1.4; integrate cli parameter handling
- ics-dm-os image recipes: fix SUMMARY resp. DESCRIPTION

## [> 3.1.11.1039] Q4 2021
- distro: disable systemd-sysusers (uids/gids created by systemd-sysusers
  could potentially clash with uids/gids introduced by later update images)

## [>= 3.1.11.x ] Q4 2021
- add kas files to build meta-ics-dm for different configurations
- implicit update to dunfell 3.1.11 (in kas/distro/poky.yaml)
- implicit update to meta-openembedded dunfell HEAD 2e7e98cd0cb82db214b13224c71134b9335a719b
  (in kas/distro/ics-dm-os.yaml)
- Readme: document default partition layout
- os-release.bbappend: adapt to meta-ics-dm layer handling in kas
- distro.conf: increase IMAGE_OVERHEAD_FACTOR to 1.1 otherwise ext4 image
  overhead will not fit into IMAGE_ROOTFS_SIZE and IMAGE_ROOTFS_EXTRA_SPACE

## [> 3.1.10.912 ] Q3 2021
- add wifi-commissioning-gatt-service
- add bluez 5.61 from poky honister (required by wifi-commissioning-gatt-service)
- enable wpa_supplicant with default config for wlan0 per default if
  DISTRO_FEATURE 'wifi' is set
- wpa_supplicant ctrl is restricted to group wpa_supplicant for
  wpa_supplicant@wlan0

## [> 3.1.10.768 ] Q3 2021
- add tmpfiles.d handling for /etc/aziot in
  /usr/lib/tmpfiles.d/iot-identity-service.conf as fallback to fix permissions
- iotedge: change dependencies to iot-identity-service from head of release/1.2 branch
  to a hard commit (head of release/1.2 branch at time iotedge repo was tagged to 1.2.x)

## [> 3.1.10.761 ] Q3 2021
- update azure-iot-sdk-c to LTS_07_2021_Ref01

## [> 3.1.9.693 ] Q3 2021
- update do-client to v0.7.0

## [> 3.1.9.676 ] Q3 2021
- fix possible deadlock in systemd-time-wait-sync.service

## [> 3.1.9.612] Q3 2021
- enrollment: remove configuration for runtime from recipe

## [> 3.1.9.544] Q3 2021
- update iot-identity-service to 1.2.2
- update iotedge to 1.2.3

## [> 3.1.8.468] Q2 2021
- fix systemds "ConditionFirstBoot" check on first boot by removing
  empty machine-id in rootfs
- write boot.scr dynamically
- expanding data is now handled by initramfs on first boot, if configured
  via DISTRO_FEATURE 'resize-data'
- removed expand-data systemd service
- removed systemd mount handling and mount dependencies
- added ics-dm-os-initramfs which mounts overlays/bind mounts before systemd
  starts
- patch u-boot to allow boot images > 8MB
- updata-ca-certificates is called on first boot, to possibly propagate
  injected certificates
- first-boot.service starts script on first boot
- patched eis_utils to propagate GatewayHostName to connection string in
  nested environments
- permission handling for manual SaS authentication in iot-identity service
- build/install iot-identity-service with tpm regardless of DISTRO_FEATURES;
  currently you can not separate aziot-tpmd from installing, aziotctl has hard
  dependencies to it

## [> 3.1.8.404]  Q2 2021
- updated iotedge to 1.2.1
- updated iot-identity-service to rev 427fe7624954118577bc083b83fa216430c2a085 from release/1.2 branch
- version schema uses pokys version + build number suffix
- initial distro config for ics-dm-os
- moved recipes depending on meta-virtualization into dynamic layer
- fix in iot-hub-device-update to use it on devices where root A is not on /dev/mmcblk0
- patches/fixes to rename u-boot partition references in adu/swupdate from "rpipart" to "bootpart"
- u-boot config with support for A/B updates for odroid-c2
- u-boot patch and env on mmc config for odroid-c2
- odroid kernel fragment for overlayfs (mandatory for our readonly rootfs)
- odroid kernel fragment for recommended systemd settings
- initial support for odroid-c2 device
- added dynamic-layers for bsps adaptions (raspberrypi and odroid)
- really disable syslog in busybox -> systemd now gets syslog messages
- removed dependency to meta-elbb
- added iot-module-template
- configurable DISTRO_FEATURES: ics-dm-demo, iotedge, tpm
- added AIS (https://github.com/Azure/iot-identity-service) for provisioning iot-hub-device-update and iotedge
- removed ics-dm-iot-hub-device-update_git.bb

## [0.1.0](pre-ais) Q2 2021

Initial Version

- if not set layer sets PREFERRED_PROVIDER_virtual/docker to "docker-moby"
- yocto image 'ics-image' based on meta-elbb 'elbb-image'
- enrollment_git.bb for auto enrollment demo (not intended for production)
- iot-hub-device-update_git.bb and ics-dm-iot-hub-device-update_git.bb provide virtual/iot-hub-device-update
- dependency recipes for iot-hub-device-update
