# ICS_DeviceManagement - meta-ics-dm yocto layer

What is ICS_DeviceManagement?: https://lp.conplement.de/ics-devicemanagement

## Features
This yocto meta layer provides yocto recipes for ICS_DeviceManagement:
- [iot-hub-device-update](https://github.com/Azure/iot-hub-device-update)
- [iot-identity-service](https://github.com/Azure/iot-identity-service)
- [iotedge](https://github.com/Azure/iotedge)

- `ics-image` a `swupdate` Image with A/B rootfs update support
- additional version information in `/etc/os-release`: `ICS_DM_IOTEDGE_YOCTO_VERSION`, which is the os image version relevant to `iot-hub-device-update`
- demo: auto device enrollment via `tpm` (not intended for production) with `tpm` provisioning configuration of `iot-identity-service`
    - `iot-hub-device-update` and `iotedge` get provisioned via `iot-identity-service`

An example integration can be found in [ics-dm-os](https://github.com/ICS-DeviceManagement/ics-dm-os).

## Compatibility
`meta-ics-dm` is compatible with the current yocto LTS release branch `dunfell`.

## Dependencies
`meta-ics-dm` depends on:
- [meta-elbb](https://github.com/elbb/meta-elbb)
- [meta-rust](https://github.com/meta-rust/meta-rust.git)
- [meta-swupdate](https://github.com/sbabic/meta-swupdate.git)
- [meta-virtualization](https://git.yoctoproject.org/git/meta-virtualization)

## Configuration

For using `ics-image` together with `iot-hub-device-update` you have to provide a rsa-key for signing/verifying the update image.
Note: We currently only support `swupdate` RSA signing.
Provide the environment Variables `SWUPDATE_PASSWORD_FILE` and `SWUPDATE_PRIVATE_KEY`.
 - `SWUPDATE_PASSWORD_FILE` - full path to a file containing the keys password
 - `SWUPDATE_PRIVATE_KEY` - full path of private key file
```sh
# How to generate SWUPDATE_PASSWORD_FILE and SWUPDATE_PRIVATE_KEY
echo "your password" > priv.pass
openssl genrsa -aes256 -passout file:priv.pass -out priv.pem
# SWUPDATE_PASSWORD_FILE = $(pwd)/priv.pass
# SWUPDATE_PRIVATE_KEY = $(pwd)/priv.pem
```

### DISTRO_FEATURES

`meta-ics-dm` is configurable via the following `DISTRO_FEATURES`:<br>
- `ics-dm-demo`
    - adds an automatic device enrollment demo via `tpm`
    - synchronizes startup of `iot-identity-service` with the enrollment demo
- `iotedge`
    - adds the `iotedge` service with its dependencies
    - adds `virtualization` to `DISTRO_FEATURES` (from meta-virtualization) needed by `iotedges` runtime dependency `moby`
- `tpm`
    - `iot-identity-service` installs `aziot-tpmd` and corresponding config files

# License

Licensed under either of

* Apache License, Version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or <http://www.apache.org/licenses/LICENSE-2.0>)
* MIT license ([LICENSE-MIT](LICENSE-MIT) or <http://opensource.org/licenses/MIT>)

at your option.

# Contribution

Unless you explicitly state otherwise, any contribution intentionally
submitted for inclusion in the work by you, as defined in the Apache-2.0
license, shall be dual licensed as above, without any additional terms or
conditions.

Copyright (c) 2021 conplement AG
