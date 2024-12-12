FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:${LAYERDIR_raspberrypi}/recipes-bsp/u-boot/files:"

SRC_URI += "\
    file://0001-rpi-always-set-fdt_addr-with-firmware-provided-FDT-address.patch \
    file://add-reset-info.patch \
    file://omnect_env_rpi.patch \
    file://enable-reset-info-cmd-fragment.cfg \
    file://redundant-env.cfg \
    file://omnect_env_rpi.h \
"

OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/dynamic-layers/raspberrypi/recipes-bsp/u-boot/u-boot_%.bbappend"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/dynamic-layers/raspberrypi/recipes-bsp/u-boot/u-boot/*"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_raspberrypi}/recipes-bsp/u-boot/u-boot_%.bbappend"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_raspberrypi}/recipes-bsp/u-boot/files/*"
# we have to update the raspberrypi firmware if basic configuration of the bsp changes
# per convention such changes should be made in the following file:
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/conf/machine/include/rpi_firmware_settings.inc"

# also embedding bootloader version influences u-boot binary, so file below has
# also to be taken into account for version checksumming
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/conf/machine/include/rpi_bootloader_embedded_version.inc"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_raspberrypi}/recipes-bsp/bootfiles/rpi-config/*"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_raspberrypi}/recipes-bsp/bootfiles/*"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_raspberrypi}/recipes-bsp/common/*"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${@bb.utils.contains('MACHINE_FEATURES', 'armstub', '${LAYERDIR_raspberrypi}/recipes-bsp/armstubs/*', '', d)}"

# we don't use fw_env.config from meta-raspberrypi
OMNECT_BOOTLOADER_CHECKSUM_FILES_GLOB_IGNORE += "${LAYERDIR_raspberrypi}/recipes-bsp/u-boot/files/fw_env.config"
OMNECT_BOOTLOADER_CHECKSUM_FILES_GLOB_IGNORE += "${@bb.utils.contains('MACHINE_FEATURES', 'armstub', '', '${LAYERDIR_raspberrypi}/recipes-bsp/common/raspberrypi-tools.inc', d)}"
# todo ignore dirs in subpath as alternative to:
OMNECT_BOOTLOADER_CHECKSUM_FILES_GLOB_IGNORE += "${LAYERDIR_raspberrypi}/recipes-bsp/bootfiles/rpi-config"

do_configure:prepend() {
    cp -f ${WORKDIR}/omnect_env_rpi.h ${S}/include/configs/omnect_env_machine.h
}
