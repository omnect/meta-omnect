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
    sed -i 's/^ICS_DM_FLASH_MODE_ETH="eth0"/ICS_DM_FLASH_MODE_ETH="${ICS_DM_ETH0}"/' ${D}/init.d/87-flash_mode
}

FILES:${PN} = "\
    /init.d/87-flash_mode \
"
