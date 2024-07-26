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

OMNECT_FLASH_MODE_BOOTLOADER_START
OMNECT_FLASH_MODE_DATA_SIZE
OMNECT_FLASH_MODE_FLAG_FILE
OMNECT_FLASH_MODE_IP_ADDR
OMNECT_FLASH_MODE_UBOOT_ENV_SIZE
OMNECT_FLASH_MODE_UBOOT_ENV1_START
OMNECT_FLASH_MODE_UBOOT_ENV2_START

OMNECT_GRUBENV_FILE
OMNECT_INITRAMFS_FSTYPE
OMNECT_KERNEL_SRC_URI
OMNECT_KERNEL_SRC_URI_LTE
OMNECT_OS_GIT_SHA
OMNECT_OS_GIT_BRANCH
OMNECT_OS_GIT_REPO
OMNECT_OS_VERSION
OMNECT_PART_OFFSET_UBOOT_ENV1
OMNECT_PART_OFFSET_UBOOT_ENV2
OMNECT_PART_SIZE_BOOT
OMNECT_PART_SIZE_CERT
OMNECT_PART_SIZE_DATA
OMNECT_PART_SIZE_ETC
OMNECT_PART_SIZE_FACTORY
OMNECT_PART_SIZE_ROOTFS
OMNECT_PART_SIZE_UBOOT_ENV
OMNECT_PART_SPARE1
OMNECT_PART_SPARE2
OMNECT_RELEASE_IMAGE
OMNECT_ROOT_DEVICE
OMNECT_UBOOT_WRITEABLE_ENV_FLAGS
OMNECT_USER_PASSWORD
OMNECT_VM_PANIC_ON_OOM
OMNECT_WAIT_ONLINE_INTERFACES_BUILD
OMNECT_WAIT_ONLINE_INTERFACES_RUN
OMNECT_WAIT_ONLINE_TIMEOUT_IN_SECS
OMNECT_WLAN0

#TODO
LAYERDIR_omnect
LAYERDIR_...
META_OMNECT_GIT_REPO
META_OMNECT_VERSION
ONLINE_INTERFACE_ARGS
