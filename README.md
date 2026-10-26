# omnect device management - meta-omnect yocto layer

Product page: <www.omnect.io>

## Features
This yocto meta layer provides the device management distribution `omnect-os`. It includes recipes for:
- [iot-hub-device-update](https://github.com/Azure/iot-hub-device-update)
- [iot-identity-service](https://github.com/Azure/iot-identity-service)
- [iotedge](https://github.com/Azure/iotedge)
- `omnect-os image`: an updatable device image with A/B rootfs update support with the following implicit features:
    - `iot-hub-device-update` and `iot-identity-service` are installed
    - `iot-hub-device-update` is provisioned as module identity via `iot-identity-service`
    - First boot script `/usr/bin/omnect_first_boot.sh` which is executed at first boot of the device; it can be adapted via `meta-omnect/recipes-core/systemd/systemd/omnect_first_boot.sh`
    - Factory reset via OS bootloader environment variable `factory-reset`
      - **Note**: This feature provides a limited level of data privacy. Please see section [Factory Reset](#factory-reset) below.
    - [Secure Boot for x86 UEFI devices](doc/efi_secure_boot.md).
    - [Mandatory Access Control (AppArmor)](doc/mac_lsm.md): the AppArmor Linux Security Module (LSM) is compiled in and its userspace is installed; DAC stays the default and AppArmor is boot-selectable.
    - [Wifi commissioning](doc/wifi_commissioning.md): join a Wi-Fi network over a BLE GATT interface or a local Unix-socket API on `wifi`-enabled images.
- `omnect-os update image`: the [`swupdate`](https://sbabic.github.io/swupdate/swupdate.html) update image with the following implicit features:
    - Updating the bootloader

### `DISTRO_FEATURES`
`omnect-os` is built with yocto [`DISTRO_FEATURES`](https://docs.yoctoproject.org/ref-manual/features.html#distro-features) = `apparmor ipv4 ipv6 polkit seccomp xattr zeroconf`.
Depending on `MACHINE_FEATURES` we also set `3g`. `wifi` and `bluetooth` are derived from `/etc/omnect/device_caps.json` instead; see [doc/wifi_commissioning.md](doc/wifi_commissioning.md).
`apparmor` enables Mandatory Access Control support; see [doc/mac_lsm.md](doc/mac_lsm.md).

`meta-omnect` adds the following `DISTRO_FEATURES`:
- `iotedge`
    - adds the `iotedge` service with its dependencies
    - adds `virtualization` to `DISTRO_FEATURES` (from [meta-virtualization](https://git.yoctoproject.org/git/meta-virtualization)) needed by `iotedge` runtime dependency `moby`
- `persistent-var-log`
    - enables a persistent /var/log which is stored in the data partition; the initramfs bind-mounts it
- `flash-mode-2`, `flash-mode-3`
    - enable flash modes 2 and 3; flash mode 1 is always available
    - please see section [Flash Modes](#flash-modes) below
- `resize-data`
    - the initramfs expands the data partition to available space on first boot

### `MACHINE_FEATURES`
`meta-omnect` extends the following `MACHINE_FEATURES`:
- `efi`
    - the initramfs is built for GRUB; without `efi` it is built for U-Boot
- `rtc`
    - set by default for every machine. A machine whose system clock is not correct when the initramfs starts (no real-time clock that keeps the time over power off) adds `rtc` to `MACHINE_FEATURES_OPTED_OUT`
    - flash mode 3 checks the TLS certificate of an HTTPS url only with this feature
- `tpm2`
    - adds tpm kernel overlay, driver and auto modprobe for raspberry pi

- omnect Secure OS feature `pstore`: add tracking of reboot reasons
	- uses either RAM of EFI variables to store kernel messages
	- adds services and scripts for setting and determining reboot
      reasons
	- for detailed information see
      [description](/doc/Feature-pstore.md) of this feature in
      [doc](/doc/) folder

### Partition Layout
`omnect-os` uses an `A/B` update partition layout with two read-only rootfs partitions.
The partition layout for devices supporting gpt:
```sh
Device           Start      End  Sectors  Size Type
/dev/mmcblkXp1    8192    90111    81920   40M Microsoft basic data
/dev/mmcblkXp2   90112  1611775  1521664  743M Linux filesystem
/dev/mmcblkXp3 1613824  3135487  1521664  743M Linux filesystem
/dev/mmcblkXp4 3137536  3342335   204800  100M Linux filesystem
/dev/mmcblkXp5 3342336  3424255    81920   40M Linux filesystem
/dev/mmcblkXp6 3424256  3506175    81920   40M Linux filesystem
/dev/mmcblkXp7 3506176 62333918 58827743 28.1G Linux filesystem

```
- `mmcblkXp1` is the `boot` partition with vfat filesystem
- `mmcblkXp2` is the read-only `rootA` partition with ext4 filesystem
- `mmcblkXp3` is the read-only `rootB` partition with ext4 filesystem
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
- `mmcblkXp2` is the read-only `rootA` partition with ext4 filesystem
- `mmcblkXp3` is the read-only `rootB` partition with ext4 filesystem
- `mmcblkXp5` is the read-only `factory` partition with ext4 filesystem
- `mmcblkXp6` is the writable `certificate` partition with ext4 filesystem
- `mmcblkXp7` is the writable `etc` overlay partition (ext4 filesystem mounted as overlayfs on `/etc`)
- `mmcblkXp8` is the writable `data` partition with ext4 filesystem

**Note1**: The partition layout is an example, sizes may differ depending on your board and image variant (development or release).<br>
**Note2**: The size of `data` depends on your sdcard/emmc/nvme size. By default it has a size of 512M. With `resize-data` in `DISTRO_FEATURES` it is resized on the first boot to the max available size.<br>
**Note3 (only for images where u-boot is used as OS bootloader)**: There is a reserved area between the boot partition and the rootA partition used for two redundant u-boot environment banks. For this purpose, the following configuration variables are used:
- `OMNECT_PART_OFFSET_UBOOT_ENV1`: offset of 1st u-boot environment bank (in KiB, decimal)
- `OMNECT_PART_OFFSET_UBOOT_ENV2`: offset of 2nd u-boot environment bank (in KiB, decimal)
- `OMNECT_PART_SIZE_UBOOT_ENV`: size of one u-boot environment bank (in KiB, decimal)

**Note4**: The initramfs is built for the partition table set in `OMNECT_PART_TABLE` (default `gpt`). A machine whose wks file uses `--ptable msdos` sets `OMNECT_PART_TABLE = "dos"`.

## Compatibility
`meta-omnect` is compatible with the current yocto LTS release branch `wrynose`.

## Supported Devices
See board specific documents [doc](/doc/) folder.

## Versioning
We reflect the used yocto version in our version schema. `omnect-os` is versioned `6.0.x.y` where `x` is yocto wrynose's patch version and `y` is the build number.

## Dependencies
Aside from hardware specific meta layers `meta-omnect` depends on:
  - [bitbake](https://git.openembedded.org/bitbake)
  - [openembedded-core](https://git.openembedded.org/openembedded-core)
  - [meta-openembedded](https://github.com/openembedded/meta-openembedded.git): `meta-filesystems`, `meta-networking`, `meta-oe` and `meta-python`
  - [meta-security](https://git.yoctoproject.org/meta-security)
  - [meta-swupdate](https://github.com/sbabic/meta-swupdate.git)
  - [meta-virtualization](https://git.yoctoproject.org/meta-virtualization)

**Note:** Detailed information can be found in respective readmes

## Build

For using `omnect-os-update-image` together with `iot-hub-device-update` you have to provide a rsa-key for signing/verifying the update image.
**Note**: We currently only support `swupdate` RSA signing.
Provide the environment variables `SWUPDATE_PASSWORD_FILE` and `SWUPDATE_PRIVATE_KEY`.
 - `SWUPDATE_PASSWORD_FILE`: full path to a file containing the keys password
 - `SWUPDATE_PRIVATE_KEY`: full path of private key file

Furthermore you have to provide the environment variable `OMNECT_USER_PASSWORD` which sets the password of the default user `omnect`.

Optionally set `OMNECT_BUILD_NUMBER` to set a meaningful build number in the distro version. The default is `0`.

There is the configuration variable `OMNECT_VM_PANIC_ON_OOM` used to define the out-of-memory (OOM) handling.

If you want to build for target `genericx86-64` have a look into the [x86-64 secure boot build chapter](doc/efi_secure_boot.md#build).

### Release vs Developer build
Set the enviroment variable `OMNECT_RELEASE_IMAGE` to `1` for release builds. The default is `0` which means it is a developer build.

Differences:
- Release build
  - default firewall config which allows input for established connections only
  - reduced serial console output (only output high priority messages).
  - local ssh login disabled (alternatively a tunneled ssh connection can be established via [omnect-cli](https://github.com/omnect/omnect-cli#creating-an-ssh-tunnel))
  - the initramfs halts on a fatal error, and still boots when the bootloader environment cannot be read
- Developer build
  - default firewall config as in Release build, additionally allow ssh connections
  - local ssh login enabled
  - includes some useful developer tools
  - the initramfs starts a debug shell on a fatal error

### Example build via `kas`

This repository provides [`kas`](https://kas.readthedocs.io/en/latest/) configuration files to build `omnect-os`.
E.g. if you want to build an `omnect-os` raspberry pi 4 image with `iotedge` support follow these steps:

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
meta-omnect/kas/feature/iotedge.yaml:\
meta-omnect/kas/feature/persistent-var-log.yaml:\
meta-omnect/kas/machine/rpi/rpi4.yaml

```
The resulting image artifacts are located in `$(pwd)/build/deploy/images/raspberrypi4-64`.<br>
The `omnect-os-image` artefact is named `omnect-os-raspberrypi4-64.wic.xz`.<br>
The `omnect-os-update-image` artefact is named `omnect-os-update-image-raspberrypi4-64.swu`.<br>
Wifi/bluetooth commissioning is controlled per machine by `/etc/omnect/device_caps.json`; see [doc/wifi_commissioning.md](doc/wifi_commissioning.md).

### Layer prioritization orchestration
If you want to add additional yocto layers to your build, you can adapt layer priorities in `conf/layer.conf`. This layer is the last in the `BBLAYERS` yocto variable when you build with our `kas` configuration files. If not, you have to possibly adapt layer prioritization values in the last layer included in `BBLAYERS`.
E.g. we reset the layer prioritization of `meta-phytec` to `9`, to ensure it is less than the prioritization of `meta-omnect`.

### Variables Glossary
[follow](doc/Variables_Glossary.md)

## Runtime configuration

The `omnect-os-image` needs post processing via [`omnect-cli`](https://github.com/omnect/omnect-cli.git) to set a mandatory `iot-identity-service` configuration. You can optionally set an `iot-hub-device-update` configuration.

### Set `iot-hub-device-update` configuration
See [omnect-cli iot-hub-device-update configuration](https://github.com/omnect/omnect-cli/blob/main/README.md#device-update-for-iot-hub-configuration).


### Set `iot-identity-service` configuration
See [omnect-cli iot-identity-service configuration](https://github.com/omnect/omnect-cli/blob/main/README.md#identity-configuration).

### Set custom kernel parameter
To set custom kernel parameters, e.g. `foo=bar` you need to write them to file `/boot/omnect_extra_bootargs_custom` in a single line and apply:
```sh
sudo -i
echo -n "foo=bar" > /boot/omnect_extra_bootargs_custom
omnect_extra_bootargs.sh set
reboot
```
From next system start on the kernel cmdline includes the parameter `foo=bar`.

### Modify set of interfaces considered when detecting online state

This is actually only one prominent case how to preset a special
configuration in the image, here a systemd environment file that
allows to define a set of interfaces which systemd shall consider
during its test for the device being online.

It can be copied into `factory` partition as described here:
[omnect-cli Copy Files into or from Image](https://github.com/omnect/omnect-cli/blob/main/README.md#copy-files-into-or-from-image)

Configuration file `systemd-networkd-wait-online.service` is set up by
default so that all existing physical network devices i.e., Ethernet, WLAN
or WWAN are capable of connecting to the internet. This means that the
device will be determined as online if at least one of those is active.

**Note:** for detailed information about how systemd generally
determines the device online state have a look at systemd's
documentation for [service systemd-networkd-wait-online](https://www.freedesktop.org/software/systemd/man/latest/systemd-networkd-wait-online.html#)

To allow for customization the service file uses the content of
environment variable `OMNECT_WAIT_ONLINE_INTERFACES` if non-empty,
otherwise the default setting `--any` gets set.

This provides the possibility to overwrite the set of online interfaces
by injecting a systemd environment file into image, e.g.
`/etc/omnect/systemd-networkd-wait-online.env`: just create a local
file with the following content and inject it into the factory
partitions of the image:

```
OMNECT_WAIT_ONLINE_INTERFACES=--interface=<interface-name>
```

Place holder `<interface-name>` needs to be replaced with the real name,
of course.
You can also specify multiple interface arguments here which need to be
either all active for online state, or only one of them if argument
`--any` is added, too.<br>
Set `OMNECT_WAIT_ONLINE_TIMEOUT_IN_SECS` to configure the timeout in seconds, default timeout is 5 minutes.  A value of 0 means no timeout.

## Usage

The initramfs is [omnect-os-init](https://github.com/omnect/omnect-os-init). Its behaviour at run time is described in the [omnect-os-init usage docs](https://github.com/omnect/omnect-os-init/blob/main/docs/usage.md). This section lists only the build settings of this layer.

### Flash Modes
Flash mode 1 is in every image. Add `flash-mode-2` or `flash-mode-3` to `DISTRO_FEATURES` to enable modes 2 and 3. See [flash modes](https://github.com/omnect/omnect-os-init/blob/main/docs/usage.md#flash-modes).

#### Flash Mode 1
See [flash mode 1](https://github.com/omnect/omnect-os-init/blob/main/docs/usage.md#flash-mode-1). The block device paths of the supported platforms are in the [doc](/doc/) folder.

#### Flash Mode 2
See [flash mode 2](https://github.com/omnect/omnect-os-init/blob/main/docs/usage.md#flash-mode-2).
- The *omnect* user of the initramfs gets its password from `OMNECT_USER_PASSWORD`, as the rootfs user.
- `OMNECT_FLASH_MODE_2_DIRECT_FLASHING = "1"` writes the disk straight from the `scp` stream, for devices with too little RAM for the image; see [Variables Glossary](doc/Variables_Glossary.md#omnect_flash_mode_2_direct_flashing).

#### Flash Mode 3
See [flash mode 3](https://github.com/omnect/omnect-os-init/blob/main/docs/usage.md#flash-mode-3). The TLS certificate of an HTTPS url is checked only on machines with `rtc` in `MACHINE_FEATURES`.

### Factory Reset
See [factory reset](https://github.com/omnect/omnect-os-init/blob/main/docs/usage.md#factory-reset). The topics of the key "preserve" are the keys of [`/etc/omnect/factory-reset.json`](recipes-omnect/omnect-device-service/omnect-device-service/factory-reset.json).

#### Custom Factory Reset Configuration
See [preserve topics](https://github.com/omnect/omnect-os-init/blob/main/docs/usage.md#preserve-topics).

#### Factory Reset Result
See [factory reset result](https://github.com/omnect/omnect-os-init/blob/main/docs/usage.md#factory-reset-result).

### Update validation
An A/B update is validated after the device boots into the updated partition, unless the update contains a bootloader update. Most of the logic is implemented in omnect-device-service repository and [documented there](https://github.com/omnect/omnect-device-service/blob/main/src/twin/firmware_update/update_validation.md). The initramfs side is described in [update validation](https://github.com/omnect/omnect-os-init/blob/main/docs/usage.md#update-validation).

### Filesystem check
See [filesystem check](https://github.com/omnect/omnect-os-init/blob/main/docs/usage.md#filesystem-check).

### Early module load
On i.MX8MM machines the initramfs loads `imx_sdma` before `switch_root`, listed in `/etc/omnect/early-modules.d/omnect.conf`; the machine variable `OMNECT_EARLY_MODULES` sets the list. See [early module load](https://github.com/omnect/omnect-os-init/blob/main/docs/usage.md#early-module-load).

### Coredumps

Process crashes are handled by `systemd-coredump`, but **no core is stored by default** on any image (`Storage=none`) - process memory, which may hold secrets, is never written to disk.

To debug a crash on a device, enable both settings per device via the writable `/etc` overlay, then reboot and reproduce:
```sh
# 1) complete cores: containerd dumps all memory (inherited by module containers)
sudo install -d /etc/systemd/system/containerd.service.d
printf '[Service]\nCoredumpFilter=all\n' | sudo tee /etc/systemd/system/containerd.service.d/10-coredump-filter.conf
# 2) keep cores on disk
sudo install -d /etc/systemd/coredump.conf.d
printf '[Coredump]\nStorage=external\n' | sudo tee /etc/systemd/coredump.conf.d/10-storage.conf
sudo reboot
```
After reproducing, retrieve the core with `coredumpctl` and analyse it with the tooling appropriate for the crashed process (for a .NET module, `dotnet-dump`).

**Note:** a stored core is raw process memory (secrets); enable this only for a debugging session and remove both drop-ins afterwards.

# License

The layer is licensed under either of

* Apache License, Version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or <http://www.apache.org/licenses/LICENSE-2.0>)
* MIT license ([LICENSE-MIT](LICENSE-MIT) or <http://opensource.org/licenses/MIT>)

at your option if not noted otherwise.

The content of `dynamic-layers/phytec/recipes-kernel/lwb-radio-firmware` is licensed under MIT license ([LICENSE-MIT](dynamic-layers/phytec/recipes-kernel/lwb-radio-firmware/COPYING.MIT)).

# Contribution

Unless you explicitly state otherwise, any contribution intentionally
submitted for inclusion in the work by you, as defined in the Apache-2.0
license, shall be dual licensed as above, without any additional terms or
conditions.

Copyright (c) 2021-2022 conplement AG
