# omnect device management - meta-omnect yocto layer

What is omnect device management?: https://lp.conplement.de/omnect-devicemanagement

## Features
This yocto meta layer provides the poky based device management distribution `omnect-os`. It includes recipes for:
- [iot-hub-device-update](https://github.com/Azure/iot-hub-device-update)
- [iot-identity-service](https://github.com/Azure/iot-identity-service)
- [iotedge](https://github.com/Azure/iotedge)
- `omnect-os image` - an updatable device image with A/B rootfs update support<br>
  implicit features:
    - `iot-hub-device-update` and `iot-identity-service` are installed
    - `iot-hub-device-update` is provisioned as module identity via `iot-identity-service`
    - first boot script `/usr/bin/omnect_first_boot.sh` which is executed at first boot of the device; it can be adapted via `meta-omnect/recipes-core/systemd/systemd/omnect_first_boot.sh`
    - factory reset via OS bootloader environment variable `factory-reset`
      - **note**: This feature provides a limited level of data privacy. Please see section [Factory Reset](#factory-reset), below.
- `omnect-os update image` - the [`swupdate`](https://sbabic.github.io/swupdate/swupdate.html) update image
    - additionally: updating the bootloader via swupdate

### `DISTRO_FEATURES`
`omnect-os` depends on [poky](https://www.yoctoproject.org/software-item/poky/).
It is built with the default `poky` `DISTRO_FEATURES`.

`meta-omnect` adds the following `DISTRO_FEATURES`:
- `iotedge`
    - adds the `iotedge` service with its dependencies
    - adds `virtualization` to `DISTRO_FEATURES` (from [meta-virtualization](https://git.yoctoproject.org/git/meta-virtualization)) needed by `iotedge` runtime dependency `moby`
- `persistent-var-log`
    - enables a persistent /var/log which is stored in the data partition
- `flash-mode`
    - provides the possibility to flash complete disk images
    - please see section *Flash Modes*, below
- `resize-data`
    - expands the data partition to available space on first boot
- [`wifi-commissioning`](https://github.com/omnect/wifi-commissioning-gatt-service.git)
    - adds a service which enables wifi commissioning via bluetooth
    - depends on `DISTRO_FEATURES` `wifi` and `bluetooth` which are not added to `DISTRO_FEATURES` automatically!
    - **note**: this is only intended for demo purposes; this is not a production ready service

### `MACHINE_FEATURES`
`meta-omnect` extends the following `MACHINE_FEATURES`:
- `tpm2`
    - adds tpm kernel overlay, driver and auto modprobe for raspberry pi

### Partition Layout
`omnect-os` uses an `A/B` update partition layout with two readonly rootfs partitions.
The partition layout for devices supporting gpt:
```sh
Device           Start      End  Sectors  Size Type
/dev/mmcblkXp1    8192    90111    81920   40M Microsoft basic data
/dev/mmcblkXp2  106496  1628159  1521664  743M Linux filesystem
/dev/mmcblkXp3 1630208  3151871  1521664  743M Linux filesystem
/dev/mmcblkXp4 3153920  3235839    81920   40M Linux filesystem
/dev/mmcblkXp5 3235840  3317759    81920   40M Linux filesystem
/dev/mmcblkXp6 3317760  3399679    81920   40M Linux filesystem
/dev/mmcblkXp7 3399680 62333918 58934239 28.1G Linux filesystem

```
- `mmcblkXp1` is the `boot` partition with vfat filesystem
- `mmcblkXp2` is the readonly `rootA` partition with ext4 filesystem
- `mmcblkXp3` is the readonly `rootB` partition with ext4 filesystem
- `mmcblkXp4` is the writable `factory` partition with ext4 filesystem
- `mmcblkXp5` is the writable `certificate` partition with ext4 filesystem
- `mmcblkXp6` is the writable `etc` overlay partition (ext4 filesystem mounted as overlayfs on `/etc`)
- `mmcblkXp7` is the writable `data` partition with ext4 filesystem

The partition layout for devices supporting mbr:
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

The size of `data` depends on your sdcard/emmc/nvme size. Per default it has a size of 512M and is resized on the first boot to the max available size.

**Only for images where u-boot is used as OS bootloader**: There is a reserved area between the boot partition and the rootA partition used for two redundant u-boot environment banks.
For this purpose, the following configuration variables are used:

- `OMNECT_PART_OFFSET_UBOOT_ENV1`
    - offset of 1st u-boot environment bank (in KiB, decimal)
- `OMNECT_PART_OFFSET_UBOOT_ENV2`
    - offset of 2nd u-boot environment bank (in KiB, decimal)
- `OMNECT_PART_SIZE_UBOOT_ENV`
    - size of one u-boot environment bank (in KiB, decimal)

## Compatibility
`meta-omnect` is compatible with the current yocto LTS release branch `kirkstone`.

## Supported Devices
See [README.device.md](./README.device.md).

## Versioning
We reflect the used poky version in our version schema. `omnect-os` is versioned via `POKY_VERSION.BUILD_NR`, `4.0.x.y` where `x` is poky kirkstone's patch version and `y` is the build number.

## Dependencies
`meta-omnect` depends on:
- mandatory:
    - [meta-openembedded](https://github.com/openembedded/meta-openembedded.git): `meta-filesystems`, `meta-networking`, `meta-oe` and `meta-python`
    - [meta-security] (https://git.yoctoproject.org/meta-security)
    - [meta-swupdate](https://github.com/sbabic/meta-swupdate.git)
    - [meta-virtualization](https://git.yoctoproject.org/meta-virtualization)
    - [poky](https://git.yoctoproject.org/poky)
- optional:
    - [meta-phytec](https://github.com/phytec/meta-phytec) (optional - via dynamic layer, phytec polis support depends on it)
    - [meta-freescale](https://github.com/Freescale/meta-freescale) (optional - via dynamic layer, phytec polis support depends on it)
    - [meta-raspberrypi](https://github.com/agherzan/meta-raspberrypi.git) (optional - via dynamic layer, raspberrypi support depends on it)


## Build

For using `omnect-os-update-image` together with `iot-hub-device-update` you have to provide a rsa-key for signing/verifying the update image.
Note: We currently only support `swupdate` RSA signing.
Provide the environment variables `SWUPDATE_PASSWORD_FILE` and `SWUPDATE_PRIVATE_KEY`.
 - `SWUPDATE_PASSWORD_FILE` - full path to a file containing the keys password
 - `SWUPDATE_PRIVATE_KEY` - full path of private key file

Furthermore you have to provide the environment variable `OMNECT_USER_PASSWORD` which sets the password of the default user `omnect`.

Optionally set `OMNECT_BUILD_NUMBER` to set a meaningful build number in the distro version. The default is `0`.

There is the configuration variable `OMNECT_VM_PANIC_ON_OOM` used to define the out-of-memory (OOM) handling.

### Release vs Developer build
Set the enviroment variable `OMNECT_RELEASE_IMAGE` to `1` for release builds. The default is `0` which means it is a developer build.

Differences:
- Release build
  - default firewall config which allows input for established connections only
- Developer build
  - default firewall config as in Release build, additionally allow ssh connections

### Example build via `kas`

This repository provides [`kas`](https://kas.readthedocs.io/en/latest/) configuration files to build `omnect-os`.
E.g. if you want to build an `omnect-os` raspberrypi 4 image with `iotedge` support for the omnect-portal (todo link to omnect-portal doku) follow these steps:

```sh
mkdir omnect-os-build
cd omnect-os-build
git clone https://github.com/omnect/meta-omnect.git

# Generate 'SWUPDATE_PASSWORD_FILE' and 'SWUPDATE_PRIVATE_KEY'
echo "your password" > priv.pass
openssl genrsa -aes256 -passout file:priv.pass -out priv.pem

# Build 'omnect-os-image' and 'omnect-os-update-image' via:
docker run --rm \
-v $(pwd):/builder \
-u 0:$(id -g) \
-e USER_ID=$(id -u) \
-e GROUP_ID=$(id -g) \
-e OMNECT_BUILD_NUMBER=1 \
-e OMNECT_USER_PASSWORD="your escaped password" \
-e SWUPDATE_PASSWORD_FILE=/builder/priv.pass \
-e SWUPDATE_PRIVATE_KEY=/builder/priv.pem \
ghcr.io/siemens/kas/kas \
kas build \
meta-omnect/kas/distro/omnect-os.yaml:\
meta-omnect/kas/example/wifi-commissioning.yaml:\
meta-omnect/kas/feature/iotedge.yaml:\
meta-omnect/kas/feature/persistent-var-log.yaml:\
meta-omnect/kas/machine/rpi/rpi4.yaml

```
The resulting image artifacts are located in `$(pwd)/build/deploy/images/raspberrypi4-64`.<br>
The `omnect-os-image` artefact is named `omnect-os-raspberrypi4-64.wic.xz`.<br>
The `omnect-os-update-image` artefact is named `omnect-os-update-image-raspberrypi4-64.swu`.<br>

### Layer prioritization orchestration
If you want to add additional yocto layers to your build, you can adapt layer priorities in `conf/layer.conf`. This layer is the last in the `BBLAYERS` yocto variable when you build with our `kas` configuration files. If not, you have to possibly adapt layer prioritization values in the last layer included in `BBLAYERS`.
E.g. we reset the layer prioritization of `meta-phytec` to `9`, to ensure it is less than the prioritization of `meta-omnect`.

## Runtime configuration

The `omnect-os-image` needs post processing via [`omnect-cli`](https://github.com/omnect/omnect-cli.git) to set a mandatory `iot-identity-service` configuration. You can optionally set an `iot-hub-device-update` configuration.

### Set `iot-hub-device-update` configuration
See [omnect-cli iot-hub-device-update configuration](https://github.com/omnect/omnect-cli/blob/main/README.md#device-update-for-iot-hub-configuration).


### Set `iot-identity-service` configuration
See [omnect-cli iot-identity-service configuration](https://github.com/omnect/omnect-cli/blob/main/README.md#identity-configuration).


## Usage

### Flash Modes
The flash modes are used to flash the complete disk image including all partitions to the target system.
It uses the initramfs context, because in this mode the block device is free for writing images.
Also, no filesystem is mounted in this state.

There are the following two flash modes:
- 1: clone disk image from the disk the system is currently running to another disk of the system
- 2: flash disk image from network to same disk the system is currently running

#### Flash Mode 1
For the flash mode 1, it is required to specify the destination disk, the current disk image will be cloned to.
For this purpose, the block device path has to be used.

The flash mode 1 behaves like a factory reset, related to the new boot device:
- reset to default bootloader environment
- enforce first boot condition
- reset *etc* partition
- reset *data* partition; optionally resize


The following example shows how to trigger the flash mode 1 using the block device path, on the target system:<br>
```sh
sudo -s
bootloader_env.sh set flash-mode 1
bootloader_env.sh set flash-mode-devpath '/dev/mmcblk2'
reboot
...
Entering omnect flashing mode 1...
...
```
**Note, the *bootloader_env.sh* command requires root permissions.**
**Note, the corresponding platform specific block device paths are defined in [README.device.md](./README.device.md).**

**Note make sure that the system boots from the same device after the triggered reboot. E.g. if you boot from usb and
initiate flash mode 1 and trigger reboot, make sure that you boot from usb again. This reboot will enter the initramfs and execute the flash process.**

After flash mode 1 has been finished successfully, the target system will be switched-off.
The bootloader environment variables *flash-mode* and *flash-mode-devpath* will be deleted automatically.

#### Flash Mode 2
Enable the distribution feature `flash-mode-2` at build time, if you want to use it.

In order to trigger the flash mode 2, use the following commands on the target system:<br>
```sh
sudo -s
bootloader_env.sh set flash-mode 2
reboot
...
Entering omnect flashing mode 2...
...
```
**Note, *bootloader_env.sh* command requires root permissions.**<br>

**Note, `flash-mode 2` is restricted to eth0.**

In the next step, the bmap file and the wic image file have to be transferred, built on the host system:
```sh
scp omnect-os-*.wic.bmap omnect@<target-ip>:wic.bmap
scp omnect-os-*.wic.xz omnect@<target-ip>:wic.xz
```
On systems with new openssh clients >= 9.0 you have to use the legacy option when using `scp`. (See [here](https://www.openssh.com/txt/release-9.0) for details.) :
```sh
scp -O omnect-os-*.wic.bmap omnect@<target-ip>:wic.bmap
scp -O omnect-os-*.wic.xz omnect@<target-ip>:wic.xz
```

The password for the *omnect* user used by the rootfs has to be used.
The *omnect* user used by the initramfs is independent from the *omnect* user used by the rootfs.
At build time, the configuration (OMNECT_USER_PASSWORD) is applied for both. The passwords are identical.
Later during runtime, changing the password in the rootfs is not synchronized to the initramfs.

The destination file names have to be *wic.bmap* and *wic.xz*.

After finishing the flash procedure, the system reboots automatically.
The bootloader environment variable *flash-mode* will be deleted automatically.
In this way, the system enters the normal mode, booting the new image.

### Factory Reset
Set the OS bootloader environment variable `factory-reset`, in order to reset `data` and `etc` partitions
```sh
sudo bootloader_env.sh set factory-reset 1
sudo reboot
```

This re-creates the corresponding filesystems of partitions `data` and `etc` on the next boot (in the initramfs context).
If the `factory` partition contains a directory `etc`, then the content is copied to the `etc` partition.

In the example above, `factory-reset` is set to the value `1`.
This means, old data is not wiped before re-creating the respective filesystems.
This kind of factory reset does not ensure any data privacy.

In order to provide higher level of privacy, the desired wipe mode can be selected.
For this purpose, the OS bootloader environment variable `factory-reset` can be set to the following values:

|     | Factory Reset Mode                                      | Remark                                     |
| --- | ------------------------------------------------------- | ------------------------------------------ |
| 1   | no wipe; only filesystems re-created                    | no privacy, but fast                       |
| 2   | use dd to write random data to etc and data partitions  | better privacy, but slow                   |
| 3   | recursive remove files with rm; notify disk with fstrim | usability depends on use case and hardware |
| 4   | custom wipe                                             |                                            |

**Note:** The provided wipe options don't guarantee total privacy. This is only possible using hardware features of the disk (e.g.; ATA secure erase).

There is also the custom wipe mode. This mode provides the possibility to address customer requirements and hardware capabilities.
In the case of custom wipe, the factory reset (initramfs context) calls `/opt/factory_reset/custom-wipe` before re-creating the filesystems inside the partitions `etc` and `data`.
In order to establish the custom wipe mode, a Yocto recipe `omnect-os-initramfs-scripts.bbappend` has to be supplied, which has to install the required utilities.

The factory reset provides the option to exclude particular files or directories.
For example, it may make sense to keep the WIFI configuration, in order to prevent loosing the network connectivity.
For this purpose, the OS bootloader environment variable `factory-reset-restore-list` has to be used for.
In the following example, the regular file `/etc/wpa_supplicant/wpa_supplicant-wlan0.conf` and the directory
`/etc/aziot/identityd/` survives the factory reset:<br>
```sh
sudo bootloader_env.sh set factory-reset-restore-list '/etc/wpa_supplicant/wpa_supplicant-wlan0.conf;/etc/aziot/identityd/'
```
```

The list of path names is separated by the character `;` and is enclosed by the `'` quotation mark.
The factory reset is directed to the partitions `etc` and `data`.
Therefore, path names with the following prefixes are allowed: `/etc/`, `/home/`, `/var/lib/`, `/var/log/`, `/usr/local/` and /mnt/data.

In the case of an error during the backup of a file or directory part of the restore list, the whole factory reset will be aborted
and the partitions `etc` and `data` remain untouched.
In the case of an error during the restore of a file or directory, the restore processing will be continued with other paths part of the restore list.
In both cases, the error will be indicated by the factory reset status (see below).

The status of the factory reset is returned by the OS bootloader environment variable `factory-reset-status`.
It has the following format:
```bnf
<factory reset status> ::= <main status>':'<subordinated status>
<main status>          ::= <unsigned integer>
<subordinated status>  ::= <unsigned integer> | '-'
```

The overall *factory reset status* consists of two parts:
- *main status*: general processing state; 0 -> wipe mode supported; 1 -> wipe mode unsupported; 2 -> backup/restore failure
- *subordinated status*: execution exit status, in case of *main status* == 0 (success)

In the case of a successfully performed factory reset, the OS bootloader environment variable `factory-reset-status` is set to the value `0:0`.

### Debug Mount Options of Data Partition

The filesystem inside the data partition is mounted using the mount options `defaults,noatime,nodiratime,async,rw`, per default.
For debugging purpose, it is possible to enforce different mount options for the data partition, using the OS bootloader environment variable `data-mount-options`:<br>
```sh
# enforce sync mount
sudo bootloader_env.sh set data-mount-options defaults,noatime,nodiratime,sync,rw
sudo reboot
...
# remove debug mount options; continue with default
sudo bootloader_env.sh unset data-mount-options
sudo reboot
```

**Note:** The bootloader environment variable `data-mount-options` should be removed at the end of the debugging session.

**Note:** It is not advised to use sync mount in operational mode.

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

Copyright (c) 2021-2022 conplement AG
