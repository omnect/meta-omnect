LICENSE = "MIT | Apache-2.0"

LIC_FILES_CHKSUM = "\
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"

inherit omnect_initramfs

IMAGE_NAME = "${OMNECT_INITRAMFS_IMAGE_NAME}"

FLASH_MODE_2_PACKAGES = " \
    bmap-tools \
    dhcpcd \
    dropbear \
    xz \
"

GRUB_SUPPORT_PACKAGES = " \
    dosfstools \
    grub-cfg \
    grub-editenv \
    grub-env \
"

RESIZE_DATA_PACKAGES = "\
    e2fsprogs-resize2fs \
    gptfdisk \
    parted \
"

UBOOT_SUPPORT_PACKAGES = " \
    libubootenv \
    libubootenv-bin \
"

PACKAGE_INSTALL = "\
    base-passwd \
    coreutils \
    e2fsprogs \
    e2fsprogs-mke2fs \
    e2fsprogs-tune2fs \
    initramfs-framework-base \
    initramfs-module-debug \
    kmod \
    omnect-os-initramfs-scripts \
    os-release \
    util-linux-fsck \
    util-linux-sfdisk \
    ${ROOTFS_BOOTSTRAP_INSTALL} \
    ${VIRTUAL-RUNTIME_base-utils} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'flash-mode-2', '${FLASH_MODE_2_PACKAGES}', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'resize-data', '${RESIZE_DATA_PACKAGES}', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'grub', '${GRUB_SUPPORT_PACKAGES}', '${UBOOT_SUPPORT_PACKAGES}', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'efi', 'efibootmgr', '', d)} \
    ${@bb.utils.contains('OMNECT_RELEASE_IMAGE', '1', '', 'initramfs-module-debug', d)} \
"

inherit ${@bb.utils.contains('DISTRO_FEATURES', 'flash-mode-2', 'omnect_user', '', d)}
