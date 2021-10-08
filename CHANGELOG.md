# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
- updated iot-identity-service to rev 427fe7624954118577bc083b83fa216430c2a085 from release/1.2 branch- version schema uses pokys version + build number suffix
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
