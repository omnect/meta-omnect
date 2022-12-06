LICENSE = "MIT | Apache-2.0"

LIC_FILES_CHKSUM = "\
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"

inherit omnect_initramfs

IMAGE_NAME = "${OMNECT_INITRAMFS_IMAGE_NAME}"

RESIZE_DATA_PACKAGES = "\
    e2fsprogs-resize2fs \
    parted \
"

PACKAGE_INSTALL = "\
    base-passwd \
    omnect-os-initramfs-scripts \
    initramfs-framework-base \
    initramfs-module-debug \
    e2fsprogs-e2fsck \
    e2fsprogs-mke2fs \
    e2fsprogs-tune2fs \
    coreutils \
    kmod \
    ${ROOTFS_BOOTSTRAP_INSTALL} \
    ${VIRTUAL-RUNTIME_base-utils} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'resize-data', '${RESIZE_DATA_PACKAGES}', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'flash-mode', 'omnect-flash-mode dhcpcd dropbear bmap-tools xz util-linux-sfdisk e2fsprogs', '', d)} \
"

PACKAGE_INSTALL += "${@ 'libubootenv libubootenv-bin' if bb.utils.to_boolean(d.getVar('UBOOT_MACHINE')) else '' }"

inherit ${@bb.utils.contains('DISTRO_FEATURES', 'flash-mode', 'omnect_user', '', d)}
