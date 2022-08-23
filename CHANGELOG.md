# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [kirkstone-0.3.14] Q3 2022
- `iot-identity-service/iotedge`: fixed provisioning of modules using request content-type different then 'application\json'

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
