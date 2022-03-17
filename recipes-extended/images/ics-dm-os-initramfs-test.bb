LICENSE = "MIT | Apache-2.0"

LIC_FILES_CHKSUM = "\
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"
inherit ics_dm_initramfs

IMAGE_NAME = "${ICS_DM_INITRAMFS_IMAGE_NAME}_test"

PACKAGE_INSTALL = "\
    base-passwd \
    initramfs-framework-base \
    initramfs-module-udev \
    udev \
    libubootenv \
    libubootenv-bin \
    ${ROOTFS_BOOTSTRAP_INSTALL} \
    ${VIRTUAL-RUNTIME_base-utils} \
    ics-dm-flash-mode \
    ics-dm-os-initramfs-scripts \
    dhcp-client dropbear bmap-tools xz \
"

inherit ics_dm_user

# enforce flash mode (see /init.d/87-flash_mode)
ROOTFS_POSTPROCESS_COMMAND:append = " ics_dm_enforce_flash_mode;"
ics_dm_enforce_flash_mode() {
    touch ${IMAGE_ROOTFS}/etc/enforce_flash_mode
}

# check consistency of script ordering
ROOTFS_POSTPROCESS_COMMAND:append = " ics_dm_initramfs_check;"
