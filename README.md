# ICS_DeviceManagement - meta-ics-dm yocto layer

What is ICS_DeviceManagement?: https://lp.conplement.de/ics-devicemanagement

## Features
This yocto meta layer provides yocto recipes for ICS_DeviceManagement:
- [iot-hub-device-update](https://github.com/Azure/iot-hub-device-update)
- [iot-identity-service](https://github.com/Azure/iot-identity-service)
- [iotedge](https://github.com/Azure/iotedge)

- `ics-os-dm-update-image` a `swupdate` Image with A/B rootfs update support
- demo: auto device enrollment via `tpm` (not intended for production) with `tpm` provisioning configuration of  `iot-identity-service`
    - `iot-hub-device-update` and `iotedge` get provisioned via `iot-identity-service`
- A/B update support for [raspberrypi](https://www.raspberrypi.org/) 3 and 4
- A/B update support for [odroid-c2](https://www.hardkernel.com/shop/odroid-c2/)

An example integration can be found in [ics-dm-os](https://github.com/ICS-DeviceManagement/ics-dm-os).

### `DISTRO_FEATURES`
`ics-dm-os` depends on [poky](https://www.yoctoproject.org/software-item/poky/).
It is built with the default `poky` `DISTRO_FEATURES`.

`meta-ics-dm` adds the following `DISTRO_FEATURES`:
- `ics-dm-demo`
    - adds an automatic device enrollment demo via `tpm`
    - synchronizes startup of `iot-identity-service` with the enrollment demo
- `iotedge`
    - adds the `iotedge` service with its dependencies
    - adds `virtualization` to `DISTRO_FEATURES` (from [meta-virtualization](https://git.yoctoproject.org/git/meta-virtualization)) needed by `iotedges` runtime dependency `moby`
- `persistent-journal`
    - enables a persistent journal which is stored in the data partition
- `resize-data`
    - expands the data partition to available space on first boot
- `tpm`
    - adds tpm kernel overlay, driver and auto modprobe.
    **Currently you have to enable it explicitly for `ics-dm-demo`, since enrollment depends hard on tpm.**)

## Compatibility
`meta-ics-dm` is compatible with the current yocto LTS release branch `dunfell`.

## Versioning
We reflect the used poky version in our version schema. `ics-dm-os` is versioned via `POKY_VERSION.BUILD_NR`, `3.1.x.y` where `x` is poky dunnfells patch version and `y` is our build number.

## Dependencies
`meta-ics-dm` depends on:
- [meta-rust](https://github.com/meta-rust/meta-rust.git) (mandatory)
- [meta-swupdate](https://github.com/sbabic/meta-swupdate.git) (mandatory)
- [meta-virtualization](https://git.yoctoproject.org/git/meta-virtualization) (optional - via dynamic layer, iotedge depends on it)
- [meta-odroid](https://github.com/akuster/meta-odroid.git") (optional - via dynamic layer, odroid-c2 support depends on it)
- [meta-raspberrypi]("https://github.com/agherzan/meta-raspberrypi.git") (optional - via dynamic layer, raspberrypi support depends on it)

## Configuration

For using `ics-dm-os-update-image` together with `iot-hub-device-update` you have to provide a rsa-key for signing/verifying the update image.
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
