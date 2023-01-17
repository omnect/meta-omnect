LICENSE = "MIT | Apache-2.0"

LIC_FILES_CHKSUM = "\
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"

inherit omnect_initramfs

IMAGE_NAME = "${OMNECT_INITRAMFS_IMAGE_NAME}"

RESIZE_DATA_PACKAGES = "\
    e2fsprogs-resize2fs \
    gptfdisk \
    parted \
"

PACKAGE_INSTALL = "\
    base-passwd \
    e2fsprogs \
    omnect-os-initramfs-scripts \
    initramfs-framework-base \
    initramfs-module-debug \
    libubootenv \
    libubootenv-bin \
    e2fsprogs-e2fsck \
    e2fsprogs-mke2fs \
    e2fsprogs-tune2fs \
    coreutils \
    kmod \
    os-release \
    util-linux-sfdisk \
    ${ROOTFS_BOOTSTRAP_INSTALL} \
    ${VIRTUAL-RUNTIME_base-utils} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'resize-data', '${RESIZE_DATA_PACKAGES}', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'flash-mode-2', 'dhcpcd dropbear bmap-tools xz', '', d)} \
"

inherit ${@bb.utils.contains('DISTRO_FEATURES', 'flash-mode-2', 'omnect_user', '', d)}
