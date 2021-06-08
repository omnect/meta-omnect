# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.1.8.x](distro) Q2 2021

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
