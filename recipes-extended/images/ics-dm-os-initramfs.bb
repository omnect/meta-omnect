LICENSE = "MIT | Apache-2.0"

LIC_FILES_CHKSUM = "\
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"

inherit ics_dm_initramfs

IMAGE_NAME = "${ICS_DM_INITRAMFS_IMAGE_NAME}"

RESIZE_DATA_PACKAGES = "\
    e2fsprogs-e2fsck \
    e2fsprogs-resize2fs \
    libubootenv \
    libubootenv-bin \
    parted \
"

PACKAGE_INSTALL = "\
    base-passwd \
    ics-dm-os-initramfs-scripts \
    initramfs-framework-base \
    initramfs-module-udev \
    udev \
    ${RESIZE_DATA_PACKAGES} \
    ${ROOTFS_BOOTSTRAP_INSTALL} \
    ${VIRTUAL-RUNTIME_base-utils} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'resize-data', '${RESIZE_DATA_PACKAGES}', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'initramfs-flash-mode', 'ics-dm-flash-mode dhcp-client dropbear bmap-tools xz', '', d)} \
"

inherit ${@bb.utils.contains('DISTRO_FEATURES', 'initramfs-flash-mode', 'ics_dm_user', '', d)}
