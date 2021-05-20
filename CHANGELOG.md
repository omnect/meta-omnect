# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
