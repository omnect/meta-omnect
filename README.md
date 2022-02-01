# ICS_DeviceManagement - meta-ics-dm yocto layer

What is ICS_DeviceManagement?: https://lp.conplement.de/ics-devicemanagement

## Features
This yocto meta layer provides the poky based ICS_DeviceManagement distribution `ics-dm-os`. It includes recipes for:
- [iot-hub-device-update](https://github.com/Azure/iot-hub-device-update)
- [iot-identity-service](https://github.com/Azure/iot-identity-service)
- [iotedge](https://github.com/Azure/iotedge)
- `ics-os-dm-image` - an updatable device image with A/B rootfs update support; respectively `ics-os-dm-update-image` - the corresponding [`swupdate`](https://sbabic.github.io/swupdate/swupdate.html) update image<br>
  supported devices:
    - [raspberrypi](https://www.raspberrypi.org/) 3 and 4
    - [phytec polis](https://www.phytec.eu/product-eu/single-board-computer/phyboard-polis/)

  implicit features:
    - `iot-hub-device-update` and `iot-identity-service` are installed
    - `iot-hub-device-update` is provisioned as module identity via `iot-identity-service`
    - first boot script `/usr/bin/ics_dm_first_boot.sh` which is executed at first boot of the device; it can be adapted via `meta-ics-dm/recipes-core/systemd/systemd/ics_dm_first_boot.sh`
    - factory reset via `u-boot` environment variable `factory-reset=1`
      - **note**: this feature does not ensure data security after a factory reset; data is not wiped out on factory reset

### `DISTRO_FEATURES`
`ics-dm-os` depends on [poky](https://www.yoctoproject.org/software-item/poky/).
It is built with the default `poky` `DISTRO_FEATURES`.

`meta-ics-dm` adds the following `DISTRO_FEATURES`:
- [`enrollment`](https://github.com/ICS-DeviceManagement/enrollment.git)
    - adds an automatic device enrollment demo with provisioning via tpm
        - it creates a tpm enrollment in your azure device provisioning service for your device
        - it creates the provisioning configuration for `iot-identity-service`
    - synchronizes startup of `iot-identity-service` with the enrollment demo
    - depends on `DISTRO_FEATURES` including `tpm` which is not added automatically!
    - **note**: this is only intended for demo purposes; this is not a production ready service
- `iotedge`
    - adds the `iotedge` service with its dependencies
    - adds `virtualization` to `DISTRO_FEATURES` (from [meta-virtualization](https://git.yoctoproject.org/git/meta-virtualization)) needed by `iotedge` runtime dependency `moby`
- `persistent-var-log`
    - enables a persistent /var/log which is stored in the data partition
- `initramfs-flash-mode`
    - provides the possibility to flash complete disk images
    - please see section *Initramfs Flash Mode*, below
- `resize-data`
    - expands the data partition to available space on first boot
- `tpm`
    - adds tpm kernel overlay, driver and auto modprobe.
    (**Currently you have to enable it explicitly for `enrollment`, since it depends hard on tpm.**)

    @todo delete it and use poky's `tpm2` instead, since we depend on a tpm 2.0 module? `tpm2` installs more dependencies then we need though. it installs tools to read and alter tpm 2.0 modules.
- `wifi-commissioning`
    - adds a service which enables wifi commissioning via bluetooth
    - depends on `DISTRO_FEATURES` `wifi` and `bluetooth` which are not added to `DISTRO_FEATURES` automatically!
    - **note**: this is only intended for demo purposes; this is not a production ready service

### `EXTRA_IMAGE_FEATURES`
`meta-ics-dm` adds the following configurable `EXTRA_IMAGE_FEATURES`:
- `ics-dm-debug`
    - enables output of connection- and identity string in `libeis_utils`, which is a dependency of `iot-module-template-rs`

### Partition Layout
`ics-dm-os` uses an `A/B` update partition layout with two readonly rootfs partitions.
The partition layout is
```sh
Device         Boot   Start      End  Sectors  Size Id Type
/dev/mmcblkXp1 *       8192    90111    81920   40M  c W95 FAT32 (LBA)
/dev/mmcblkXp2       106496  1628159  1521664  743M 83 Linux
/dev/mmcblkXp3      1630208  3151871  1521664  743M 83 Linux
/dev/mmcblkXp4      3153918 31116287 27962370 13.3G  f W95 Ext'd (LBA)
/dev/mmcblkXp5      3153920  3235839    81920   40M 83 Linux
/dev/mmcblkXp6      3244032  3325951    81920   40M 83 Linux
/dev/mmcblkXp7      3334144  3416063    81920   40M 83 Linux
/dev/mmcblkXp8      3424256 31116287 27692032 13.2G 83 Linux
```
- `mmcblkXp1` is the `boot` partition with vfat filesystem
- `mmcblkXp2` is the readonly `rootA` partition with ext4 filesystem
- `mmcblkXp3` is the readonly `rootB` partition with ext4 filesystem
- `mmcblkXp5` is the writable `factory` partition with ext4 filesystem
- `mmcblkXp6` is the writable `certificate` partition with ext4 filesystem
- `mmcblkXp7` is the writable `etc` overlay partition (ext4 filesystem mounted as overlayfs on `/etc`)
- `mmcblkXp8` is the writable `data` partition with ext4 filesystem

The size of `mmcblkXp8` depends on your sdcard/emmc size. Per default it has a size of 512M and is resized on the first boot to the max available size.

There is a reserved area between the boot partition and the rootA partition used for two redundant u-boot environment banks.
For this purpose, the following configuration variables are used:

- `ICS_DM_PART_OFFSET_UBOOT_ENV1`
    - offset of 1st u-boot environment bank (in KiB, decimal)
- `ICS_DM_PART_OFFSET_UBOOT_ENV2`
    - offset of 2nd u-boot environment bank (in KiB, decimal)
- `ICS_DM_PART_SIZE_UBOOT_ENV`
    - size of one u-boot environment bank (in KiB, decimal)

## Compatibility
`meta-ics-dm` is compatible with the current yocto LTS release branch `dunfell`.

## Versioning
We reflect the used poky version in our version schema. `ics-dm-os` is versioned via `POKY_VERSION.BUILD_NR`, `3.1.x.y` where `x` is poky dunnfell's patch version and `y` is our build number.

## Dependencies
`meta-ics-dm` depends on:
- mandatory:
    - [meta-openembedded](https://github.com/openembedded/meta-openembedded.git): `meta-filesystems`, `meta-networking`, `meta-oe` and `meta-python`
    - [meta-rust](https://github.com/meta-rust/meta-rust.git)
    - [meta-swupdate](https://github.com/sbabic/meta-swupdate.git)
    - [poky](https://git.yoctoproject.org/poky)
- optional:
    - [meta-virtualization](https://git.yoctoproject.org/git/meta-virtualization) (optional - via dynamic layer, `iotedge` depends on it)
    - [meta-phytec](https://github.com/phytec/meta-phytec) (optional - via dynamic layer, phytec polis support depends on it)
    - [meta-freescale](https://github.com/Freescale/meta-freescale) (optional - via dynamic layer, phytec polis support depends on it)
    - [meta-raspberrypi](https://github.com/agherzan/meta-raspberrypi.git) (optional - via dynamic layer, raspberrypi support depends on it)


## Build

For using `ics-dm-os-update-image` together with `iot-hub-device-update` you have to provide a rsa-key for signing/verifying the update image.
Note: We currently only support `swupdate` RSA signing.
Provide the environment variables `SWUPDATE_PASSWORD_FILE` and `SWUPDATE_PRIVATE_KEY`.
 - `SWUPDATE_PASSWORD_FILE` - full path to a file containing the keys password
 - `SWUPDATE_PRIVATE_KEY` - full path of private key file

Furthermore you have to provide the environment variable `ICS_DM_USER_PASSWORD` which sets the password of the default user `ics-dm`.

Optionally set `ICS_DM_BUILD_NUMBER` to set a meaningful build number in the distro version. The default is `0`.

### Example build via `kas`

This repository provides [`kas`](https://kas.readthedocs.io/en/latest/) configuration files to build `ics-dm-os`.
E.g. if you want to build an `ics-dm-os` raspberrypi 4 image with `iotedge` support for the demo-portal (todo link to demo-portal doku) follow these steps:

```sh
git clone https://github.com/ICS-DeviceManagement/meta-ics-dm.git

# Generate 'SWUPDATE_PASSWORD_FILE' and 'SWUPDATE_PRIVATE_KEY'
echo "your password" > priv.pass
openssl genrsa -aes256 -passout file:priv.pass -out priv.pem

# Build 'ics-dm-os-image' and 'ics-dm-os-update-image' via:
docker run --rm \
-v $(pwd):/builder \
-e USER_ID=$(id -u) \
-e GROUP_ID=$(id -g) \
-e ICS_DM_BUILD_NUMBER=1 \
-e ICS_DM_USER_PASSWORD=ics-dm \
-e SWUPDATE_PASSWORD_FILE=/builder/priv.pass \
-e SWUPDATE_PRIVATE_KEY=/builder/priv.pem \
ghcr.io/siemens/kas/kas \
kas build \
meta-ics-dm/kas/distro/ics-dm-os.yaml:\
meta-ics-dm/kas/feature/ics-dm-os-common.yaml:\
meta-ics-dm/kas/feature/iotedge.yaml:\
meta-ics-dm/kas/feature/wifi-commissioning.yaml:\
meta-ics-dm/kas/feature/persistent-var-log.yaml:\
meta-ics-dm/kas/machine/rpi/rpi4.yaml

```
The resulting image artifacts are located in `$(pwd)/build/deploy/images/raspberrypi4-64`.<br>
The `ics-dm-os-image` artefact is named `ics-dm-os-raspberrypi4-64.wic.xz`.<br>
The `ics-dm-os-update-image` artefact is named `ics-dm-os-update-image-raspberrypi4-64.swu`.<br>

### Layer prioritization orchestration
If you want to add additional yocto layers to your build, you can adapt layer priorities in `conf/layer.conf`. This layer is the last in the `BBLAYERS` yocto variable when you build with our `kas` configuration files. If not, you have to possibly adapt layer prioritization values in the last layer included in `BBLAYERS`.
E.g. we reset the layer prioritization of `meta-phytec` to `9`, to ensure it is less then the prioritization of `meta-ics-dm`.

## Runtime configuration

The `ics-dm-os-image` needs postprocessing via [`ics-dm-cli`](https://github.com/ICS-DeviceManagement/ics-dm-cli.git) to set a mandatory `iot-identity-service` configuration. Furthermore you need to set an `enrollment` configuration if `DISTRO_FEATURES` contains `enrollment`. You can optionally set an `iot-hub-device-update` configuration.

### Set `enrollment` configuration
See [ics-dm-cli enrollment configuration](https://github.com/ICS-DeviceManagement/ics-dm-cli/blob/main/README.md#enrollment-configuration).

### Set `iot-hub-device-update` configuration
See [ics-dm-cli iot-hub-device-update configuration](https://github.com/ICS-DeviceManagement/ics-dm-cli/blob/main/README.md#device-update-for-iot-hub-configuration).


### Set `iot-identity-service` configuration
See [ics-dm-cli iot-identity-service configuration](https://github.com/ICS-DeviceManagement/ics-dm-cli/blob/main/README.md#identity-configuration).


## Usage

### Initramfs Flash Mode
This mode is used to flash the complete disk image including all partitions to the target system.
It uses the initramfs context, because in this mode the block device is free for writing images.
Enable the distribution feature `initramfs-flash-mode` at build time, if you want to use it.

In order to trigger the Initramfs Flash Mode, use the following commands on the target system:
```sh
sudo -s
fw_setenv initramfs-flash-mode 1
reboot
...
Entering ICS DM flashing mode...
...
```
Note, the *fw_setenv* command requires root permissions.

In the next step, the bmap file and the wic image file have to be transferred, built on the host system:
```sh
scp ics-dm-os-*.wic.bmap ics-dm@<target-ip>:wic-image.bmap
scp ics-dm-os-*.wic.xz ics-dm@<target-ip>:wic-image.fifo.xz
```
The password for the *ics-dm* user used by the rootfs has to be used.
The *ics-dm* user used by the initramfs is independent from the *ics-dm* user used by the rootfs.
At build time, the configuration (ICS_DM_USER_PASSWORD) is applied for both. The passwords are identical.
Later during runtime, changing the password in the rootfs is not synchronized to the initramfs.

The destination file names have to be *wic-image.bmap* and *wic-image.fifo.xz*.

After finishing the flash procedure, the system reboots automatically.
The u-boot environment variable *initramfs-flash-mode* will be deleted automatically.
In this way, the system enters the normal mode, booting the new image.

### Factory reset
Set u-boot env var `factory-reset` to reset `data` and `etc` partition.
```sh
sudo fw_setenv factory-reset 1
```
This recrates the corresponding filesystem of partitions `data` and `etc` on the next boot. If the `factory` partition contains a directory `etc`, then the content is copied to the `etc` partition.

**Note:** The factory reset does not ensure data security. The old data is not wiped before recreating the respectively filesystem.

# Todo's
- document: image needs postprocessing via `ics-dm-cli` to get
  - mandatory: an `iot-identity-service` configuration (provisioning)
  - mandatory if activated: an `enrollment` configuration
  - optional: an `iot-hub-device-update` configuration
- document: kas usage with example `kas/ics-dm-os-iot-rpi3.yaml` and
  `kas/ics-dm-os-iotedge-rpi4.yaml` and how to add features
- ??? document flashing/updating an example rpi4 device???
- document layer priority orchestration in layer.conf
- document https://github.com/ICS-DeviceManagement/meta-ics-dm/pull/45#discussion_r783841596
- implement higher levels of privacy options for factory reset

# License

The layer is licensed under either of

* Apache License, Version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or <http://www.apache.org/licenses/LICENSE-2.0>)
* MIT license ([LICENSE-MIT](LICENSE-MIT) or <http://opensource.org/licenses/MIT>)

at your option if not noted otherwise.

The content of `dynamic-layers/phytec/recipes-kernel/lwb-radio-firmware` is licensed under MIT license ([LICENSE-MIT](dynamic-layers/phytec/recipes-kernel/lwb-radio-firmware/COPYING.MIT)).

The content of `dynamic-layers/phytec/recipes-bsp/imx-mkimage/imx-boot-phytec*` is licensed under MIT license ([LICENSE-MIT](https://git.phytec.de/meta-phytec/tree/COPYING.MIT?h=dunfell)).

# Contribution

Unless you explicitly state otherwise, any contribution intentionally
submitted for inclusion in the work by you, as defined in the Apache-2.0
license, shall be dual licensed as above, without any additional terms or
conditions.

Copyright (c) 2021 conplement AG
