OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/dynamic-layers/raspberrypi/recipes-bsp/u-boot/u-boot_%.bbappend"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/dynamic-layers/raspberrypi/recipes-bsp/u-boot/u-boot/*"
# the u-boot_%.bbappend from meta-raspberrypi is part of BBMASK and thus not part of OMNECT_BOOTLOADER_CHECKSUM_FILES
#OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_raspberrypi}/recipes-bsp/u-boot/u-boot_%.bbappend"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_raspberrypi}/recipes-bsp/u-boot/files/*"
# we have to update the raspberrypi firmware if basic configuration of the bsp changes
# per convention such changes should be made in the following file:
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/conf/machine/include/rpi_firmware_settings.inc"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/conf/machine/include/rpi-slb9670.inc"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/conf/machine/include/tpm-slb9670.inc"

# also embedding bootloader version influences u-boot binary, so file below has
# also to be taken into account for version checksumming
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/conf/machine/include/rpi_bootloader_embedded_version.inc"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_raspberrypi}/recipes-bsp/bootfiles/rpi-config/*"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/conf/machine/include/rpi-pstore.inc"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_raspberrypi}/recipes-bsp/bootfiles/*"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_raspberrypi}/recipes-bsp/common/*"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${@bb.utils.contains('MACHINE_FEATURES', 'armstub', '${LAYERDIR_raspberrypi}/recipes-bsp/armstubs/*', '', d)}"

# we don't use fw_env.config from meta-raspberrypi
OMNECT_BOOTLOADER_CHECKSUM_FILES_GLOB_IGNORE += "${LAYERDIR_raspberrypi}/recipes-bsp/u-boot/files/fw_env.config"
OMNECT_BOOTLOADER_CHECKSUM_FILES_GLOB_IGNORE += "${@bb.utils.contains('MACHINE_FEATURES', 'armstub', '', '${LAYERDIR_raspberrypi}/recipes-bsp/common/raspberrypi-tools.inc', d)}"
