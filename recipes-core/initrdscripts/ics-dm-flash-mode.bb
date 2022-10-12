#
#  Provide dedicated initramfs script for flashing images
#

FILESEXTRAPATHS:prepend := "${THISDIR}/ics-dm-os-initramfs:"

LICENSE = "MIT | Apache-2.0"

LIC_FILES_CHKSUM = "\
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"

SRC_URI = "\
    file://flash-mode \
"

do_install() {
    install -m 0755 -D ${WORKDIR}/flash-mode ${D}/init.d/87-flash_mode
    # set variables templates
    sed -i -e 's|^\(ICS_DM_FLASH_MODE_ETH\)="UNDEFINED"|\1="${ICS_DM_ETH0}"|' \
           -e 's|^\(ICS_DM_FLASH_MODE_UBOOT_ENV1_START\)="UNDEFINED"|\1="${ICS_DM_PART_OFFSET_UBOOT_ENV1}"|' \
           -e 's|^\(ICS_DM_FLASH_MODE_UBOOT_ENV2_START\)="UNDEFINED"|\1="${ICS_DM_PART_OFFSET_UBOOT_ENV2}"|' \
           -e 's|^\(ICS_DM_FLASH_MODE_UBOOT_ENV_SIZE\)="UNDEFINED"|\1="${ICS_DM_PART_SIZE_UBOOT_ENV}"|' \
           -e 's|^\(ICS_DM_FLASH_MODE_DATA_SIZE\)="UNDEFINED"|\1="${ICS_DM_PART_SIZE_DATA}"|' \
              ${D}/init.d/87-flash_mode
    if [ -n "${BOOTLOADER_SEEK}" ]; then
        sed -i -e 's|^\(ICS_DM_FLASH_MODE_BOOTLOADER_START\)="UNDEFINED"|\1="${BOOTLOADER_SEEK}"|' ${D}/init.d/87-flash_mode
    fi
}

FILES:${PN} = "\
    /init.d/87-flash_mode \
"
