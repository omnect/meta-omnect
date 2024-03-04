FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://add-reset-info.patch \
    file://enable-reset-info-cmd-fragment.cfg \
    file://omnect_env.patch \
    file://rpi-always-set-fdt_addr-with-firmware-provided-FDT-address.patch \
    file://omnect_env_rpi.h \
"

OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/dynamic-layers/raspberrypi/recipes-bsp/u-boot/u-boot_%.bbappend"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/dynamic-layers/raspberrypi/recipes-bsp/u-boot/u-boot/*"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_raspberrypi}/recipes-bsp/u-boot/u-boot_%.bbappend"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_raspberrypi}/recipes-bsp/u-boot/files/*"
# we have to update the raspberrypi firmware if basic configuration of the bsp changes
# per convention such changes should be made in the following file:
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/conf/machine/include/rpi_firmware_settings.inc"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/dynamic-layers/raspberrypi/recipes-bsp/rpi-bootfiles/*"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_raspberrypi}/recipes-bsp/bootfiles/*"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_raspberrypi}/recipes-bsp/common/*"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${@bb.utils.contains('MACHINE_FEATURES', 'armstub', '${LAYERDIR_raspberrypi}/recipes-bsp/armstubs/*', '', d)}"

# we don't use fw_env.config from meta-raspberrypi
OMNECT_BOOTLOADER_CHECKSUM_FILES_GLOB_IGNORE += "${LAYERDIR_raspberrypi}/recipes-bsp/u-boot/files/fw_env.config"
OMNECT_BOOTLOADER_CHECKSUM_FILES_GLOB_IGNORE += "${@bb.utils.contains('MACHINE_FEATURES', 'armstub', '', '${LAYERDIR_raspberrypi}/recipes-bsp/common/raspberrypi-tools.inc', d)}"

do_configure:prepend() {
    cp -f ${WORKDIR}/omnect_env_rpi.h ${S}/include/configs/omnect_env_machine.h
}
