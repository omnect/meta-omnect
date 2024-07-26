# OMNECT_ADU_DEVICEPROPERTIES_COMPATIBILITY_ID
Used to configure compatibility between online updates. E.g. if you increase from `0` to `1` an online update via omnect portal is not possible.
You have to reflash the device with the new image version containing OMNECT_ADU_DEVICEPROPERTIES_COMPATIBILITY_ID = "1".
Part of `compatPropertyNames`, see https://learn.microsoft.com/en-us/azure/iot-hub-device-update/device-update-plug-and-play.

# OMNECT_ADU_DEVICEPROPERTIES_MANUFACTURER
Sets `ADUC_DEVICEPROPERTIES_MANUFACTURER` for iot-hub-device-update. See https://learn.microsoft.com/en-us/azure/iot-hub-device-update/device-update-plug-and-play#device-properties.

# OMNECT_ADU_DEVICEPROPERTIES_MODEL
Sets `ADUC_DEVICEPROPERTIES_MODEL` for iot-hub-device-update. See https://learn.microsoft.com/en-us/azure/iot-hub-device-update/device-update-plug-and-play#device-properties.

# OMNECT_ADU_MANUFACTURER
Sets `ADUC_DEVICEINFO_MANUFACTURER` for iot-hub-device-update. See https://learn.microsoft.com/en-us/azure/iot-hub-device-update/device-update-configuration-file (aduc_manufacturer).

# OMNECT_ADU_MODEL
Sets `ADUC_DEVICEINFO_MODEL` for iot-hub-device-update. See https://learn.microsoft.com/en-us/azure/iot-hub-device-update/device-update-configuration-file (aduc_model).

# OMNECT_BOOT_SCR_NAME
Name of u-boot bootscript to be generated for devices using u-boot as bootloader. Default is "boot.scr".

# OMNECT_BOOTLOADER_CHECKSUM_COMPATIBLE
See https://github.com/omnect/meta-omnect/blob/main/classes/omnect_bootloader_versioning.bbclass.

# OMNECT_BOOTLOADER_CHECKSUM_EXPECTED
See https://github.com/omnect/meta-omnect/blob/main/classes/omnect_bootloader_versioning.bbclass.

# OMNECT_BOOTLOADER_CHECKSUM_FILES
See https://github.com/omnect/meta-omnect/blob/main/classes/omnect_bootloader_versioning.bbclass.

# OMNECT_BOOTLOADER_CHECKSUM_FILES_GLOB_IGNORE
See https://github.com/omnect/meta-omnect/blob/main/classes/omnect_bootloader_versioning.bbclass.

# OMNECT_BOOTLOADER_EMBEDDED_VERSION_BBTARGET
See https://github.com/omnect/meta-omnect/blob/main/classes/omnect_uboot_embedded_version.bbclass.

# OMNECT_BOOTLOADER_EMBEDDED_VERSION_BINFILE
See https://github.com/omnect/meta-omnect/blob/main/classes/omnect_uboot_embedded_version.bbclass.

# OMNECT_BOOTLOADER_EMBEDDED_VERSION_FILLBYTE
See https://github.com/omnect/meta-omnect/blob/main/classes/omnect_uboot_embedded_version.bbclass.

# OMNECT_BOOTLOADER_EMBEDDED_VERSION_IMAGEGZ
See https://github.com/omnect/meta-omnect/blob/main/classes/omnect_uboot_embedded_version.bbclass.

# OMNECT_BOOTLOADER_EMBEDDED_VERSION_IMAGEOFFSET
See https://github.com/omnect/meta-omnect/blob/main/classes/omnect_uboot_embedded_version.bbclass.

# OMNECT_BOOTLOADER_EMBEDDED_VERSION_IMAGESIZE
See https://github.com/omnect/meta-omnect/blob/main/classes/omnect_uboot_embedded_version.bbclass.

# OMNECT_BOOTLOADER_EMBEDDED_VERSION_LOCATION
See https://github.com/omnect/meta-omnect/blob/main/classes/omnect_uboot_embedded_version.bbclass.

# OMNECT_BOOTLOADER_EMBEDDED_VERSION_MAGIC
See https://github.com/omnect/meta-omnect/blob/main/classes/omnect_uboot_embedded_version.bbclass.

# OMNECT_BOOTLOADER_EMBEDDED_VERSION_PARAMSIZE
See https://github.com/omnect/meta-omnect/blob/main/classes/omnect_uboot_embedded_version.bbclass.

# OMNECT_BOOTLOADER_EMBEDDED_VERSION_TYPE
See https://github.com/omnect/meta-omnect/blob/main/classes/omnect_uboot_embedded_version.bbclass.

# OMNECT_BOOTLOADER_VERSION_CHECK_DISABLE
See https://github.com/omnect/meta-omnect/blob/main/classes/omnect_bootloader_versioning.bbclass.

# OMNECT_BUILD_NUMBER
`OMNECT_BUILD_NUMBER` is appended to the upstream yocto version and thus part of [`DISTRO_VERSION`](https://docs.yoctoproject.org/ref-manual/variables.html#term-DISTRO_VERSION).

# OMNECT_DEVEL_TOOLS
List of tools which get installed into a omnect-os devel image.

# OMNECT_FDT_LOAD_NAME
Name of u-boot device-tree bootscript to be generated for devices using u-boot as bootloader. Default is "fdt-load.scr".

# OMNECT_FLASH_DEVPATH_VAR
Used in ['flash-mode-1'](https://github.com/omnect/meta-omnect?tab=readme-ov-file#flash-mode-1) initrd script. Contains the path to the target flash device.

# OMNECT_FLASH_MODE
Used in flash-mode initrd scripts. Is either 1,2 or 3.

# OMNECT_FLASH_MODE_BOOTLOADER_START
# OMNECT_FLASH_MODE_DATA_SIZE
# OMNECT_FLASH_MODE_FLAG_FILE
# OMNECT_FLASH_MODE_IP_ADDR
# OMNECT_FLASH_MODE_UBOOT_ENV_SIZE
# OMNECT_FLASH_MODE_UBOOT_ENV1_START
# OMNECT_FLASH_MODE_UBOOT_ENV2_START

# OMNECT_GRUBENV_FILE
Path to grubenv file in buildsystem. Defaults to `${LAYERDIR_omnect}/files/grubenv`. Relevant for devices which use grub as bootloader, such as genericx86-64.

# OMNECT_INITRAMFS_FSTYPE
In reference to [INITRAMFS_FSTYPES](https://docs.yoctoproject.org/ref-manual/variables.html#term-INITRAMFS_FSTYPES) the `FSTYPE` of out initramfs artefact. E.g. `cpio.gz` vs `cpio.gz.u-boot`.

# OMNECT_KERNEL_SRC_URI
Variable appended to virtual/kernel recipes [SRC_URI](https://docs.yoctoproject.org/ref-manual/variables.html#term-SRC_URI).

# OMNECT_KERNEL_SRC_URI_LTE
Variable appended to virtual/kernel recipes [SRC_URI](https://docs.yoctoproject.org/ref-manual/variables.html#term-SRC_URI) in case `3g` is in [MACHINE_FEATURES](https://docs.yoctoproject.org/ref-manual/variables.html#term-MACHINE_FEATURES).

# OMNECT_PART_OFFSET_UBOOT_ENV1
Offset of u-boot environment 1 in omnect-os-image. Machine specific configuration which is used in wic file to generate the omnect-os image and in u-boot + u-boot userspace tooling to access the u-boot environment.
*Note*: Currently the redundant u-boot environment is part of the omnect-os-image.
*Note*: This variable is used to create u-boot userspace runtime config files and the omnect-os-image. If you want to configure the u-boot env offset for u-boot, you have to set it in the appropriate u-boot redundant-env.cfg file, e.g.
https://github.com/omnect/meta-omnect/blob/main/dynamic-layers/raspberrypi/recipes-bsp/u-boot/u-boot/redundant-env.cfg.

# OMNECT_PART_OFFSET_UBOOT_ENV2
Offset of u-boot environment 2 in omnect-os-image. Machine specific configuration which is used in wic file to generate the omnect-os image and in u-boot + u-boot userspace tooling to access the u-boot environment.
*Note*: Currently the redundant u-boot environment is part of the omnect-os-image.
*Note*: This variable is used to create u-boot userspace runtime config files and the omnect-os-image. If you want to configure the u-boot env offset for u-boot, you have to set it in the appropriate u-boot redundant-env.cfg file, e.g.
https://github.com/omnect/meta-omnect/blob/main/dynamic-layers/raspberrypi/recipes-bsp/u-boot/u-boot/redundant-env.cfg.

# OMNECT_PART_SIZE_BOOT
Size of boot partition. See [partition layout](https://github.com/omnect/meta-omnect?tab=readme-ov-file#partition-layout).

# OMNECT_PART_SIZE_CERT
Size of certificate partition. See [partition layout](https://github.com/omnect/meta-omnect?tab=readme-ov-file#partition-layout).

# OMNECT_PART_SIZE_DATA
Size of data partition. Gets increased to available space on first boot, if `resize-data` is in [DISTRO_FEATURES](https://docs.yoctoproject.org/ref-manual/variables.html#term-MACHINE_FEATURES).

# OMNECT_PART_SIZE_ETC
Size of etc overlay parition. See [partition layout](https://github.com/omnect/meta-omnect?tab=readme-ov-file#partition-layout).

# OMNECT_PART_SIZE_FACTORY
Size of factory parition. See [partition layout](https://github.com/omnect/meta-omnect?tab=readme-ov-file#partition-layout).

# OMNECT_PART_SIZE_ROOTFS
Size of rootA resp. rootB parition. See [partition layout](https://github.com/omnect/meta-omnect?tab=readme-ov-file#partition-layout).

# OMNECT_PART_SIZE_UBOOT_ENV
Size of u-boot environment.
*Note*: This variable is used to create u-boot userspace runtime config files and the omnect-os-image. If you want to configure the u-boot env size for u-boot, you have to set it in the appropriate u-boot redundant-env.cfg file, e.g.
https://github.com/omnect/meta-omnect/blob/main/dynamic-layers/raspberrypi/recipes-bsp/u-boot/u-boot/redundant-env.cfg.

# OMNECT_RELEASE_IMAGE
Boolean to reflect if a devel or a release image gets build.
If set to `OMNECT_RELEASE_IMAGE=1` no `OMNECT_DEVEL_TOOLS` get installed. Getty is disabled. U-boot and grub are configured to be non-interruptible and silent as possible. Kernel is silent on ttyS0. Local ssh access via omnect user is disabled.

# OMNECT_UBOOT_WRITEABLE_ENV_FLAGS

# OMNECT_USER_PASSWORD
# OMNECT_VM_PANIC_ON_OOM
# OMNECT_WAIT_ONLINE_INTERFACES
# OMNECT_WAIT_ONLINE_TIMEOUT_IN_SECS

#TODO
LAYERDIR_omnect
LAYERDIR_...
META_OMNECT_GIT_REPO
META_OMNECT_VERSION
