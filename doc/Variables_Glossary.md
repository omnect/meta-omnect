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
List of tools which get installed into an omnect-os devel image.

# OMNECT_FDT_LOAD_NAME
Name of u-boot device-tree bootscript to be generated for devices using u-boot as bootloader. Default is "fdt-load.scr".

# OMNECT_FLASH_MODE_2_DIRECT_FLASHING
If value is 1 [flash-mode-2](https://github.com/omnect/meta-omnect?tab=readme-ov-file#flash-mode-2) directly flashes the image. Default is unset.
Normally we save the incoming image to RAM and verify it before we flash. On devices with a minimal RAM configuration this can fail. In this case you can skip the verifying and flash directly.

# OMNECT_GRUBENV_FILE
Path to grubenv file in buildsystem. Defaults to `${LAYERDIR_omnect}/files/grubenv`. Relevant for devices which use grub as bootloader, such as genericx86-64.

# OMNECT_INITRAMFS_FSTYPE
In reference to [INITRAMFS_FSTYPES](https://docs.yoctoproject.org/ref-manual/variables.html#term-INITRAMFS_FSTYPES) the `FSTYPE` of our initramfs artefact. E.g. `cpio.gz` vs `cpio.gz.u-boot`.

# OMNECT_KERNEL_SRC_URI
Variable appended to virtual/kernel recipes [SRC_URI](https://docs.yoctoproject.org/ref-manual/variables.html#term-SRC_URI).

# OMNECT_KERNEL_SRC_URI_LTE
Variable appended to virtual/kernel recipes [SRC_URI](https://docs.yoctoproject.org/ref-manual/variables.html#term-SRC_URI) in case `3g` is in [MACHINE_FEATURES](https://docs.yoctoproject.org/ref-manual/variables.html#term-MACHINE_FEATURES).

# OMNECT_PART_OFFSET_UBOOT_ENV1
Offset of the first u-boot environment in omnect-os-image. Machine specific configuration which is used in wic file to generate the omnect-os image and in u-boot + u-boot userspace tooling to access the u-boot environment.
*Note*: Currently the redundant u-boot environment is part of the omnect-os-image.
*Note*: This variable is used to create u-boot userspace runtime config files and the omnect-os-image. If you want to configure the u-boot env offset for u-boot, you have to set it in the appropriate u-boot redundant-env.cfg file, e.g.
https://github.com/omnect/meta-omnect/blob/main/dynamic-layers/raspberrypi/recipes-bsp/u-boot/u-boot/redundant-env.cfg.

# OMNECT_PART_OFFSET_UBOOT_ENV2
Offset of the second u-boot environment in omnect-os-image. Machine specific configuration which is used in wic file to generate the omnect-os image and in u-boot + u-boot userspace tooling to access the u-boot environment.
*Note*: Currently the redundant u-boot environment is part of the omnect-os-image.
*Note*: This variable is used to create u-boot userspace runtime config files and the omnect-os-image. If you want to configure the u-boot env offset for u-boot, you have to set it in the appropriate u-boot redundant-env.cfg file, e.g.
https://github.com/omnect/meta-omnect/blob/main/dynamic-layers/raspberrypi/recipes-bsp/u-boot/u-boot/redundant-env.cfg.

# OMNECT_PART_SIZE_BOOT
Size of boot partition. See [partition layout](https://github.com/omnect/meta-omnect?tab=readme-ov-file#partition-layout).

# OMNECT_PART_SIZE_CERT
Size of certificate partition. See [partition layout](https://github.com/omnect/meta-omnect?tab=readme-ov-file#partition-layout).

# OMNECT_PART_SIZE_DATA
Size of data partition. Gets increased to available space on first boot, if `resized-data` is in [DISTRO_FEATURES](https://docs.yoctoproject.org/ref-manual/variables.html#term-MACHINE_FEATURES).

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
Additional u-boot flags which have to be writable. See `CONFIG_ENV_FLAGS_LIST_STATIC` in upstream [documentation](https://github.com/u-boot/u-boot/blob/v2022.01/README).

# OMNECT_USER_PASSWORD
Password of the omnect user. Default is "omnect".

# OMNECT_VM_PANIC_ON_OOM
Default [vm.panic_on_oom](https://www.kernel.org/doc/html/v5.15/admin-guide/sysctl/vm.html#panic-on-oom) setting for the linux kernel virtual memory subsystem.

# OMNECT_WAIT_ONLINE_INTERFACES
See https://github.com/omnect/meta-omnect?tab=readme-ov-file#modify-set-of-interfaces-considered-when-detecting-online-state.

# OMNECT_WAIT_ONLINE_TIMEOUT_IN_SECS
See https://github.com/omnect/meta-omnect?tab=readme-ov-file#modify-set-of-interfaces-considered-when-detecting-online-state.
