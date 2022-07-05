# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [kirkstone-0.2.0] Q3 2022
- merged changes from dunfell: dunfell-1.3.8 - dunfell-1.5.0

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
