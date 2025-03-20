LICENSE = "MIT | Apache-2.0"

LIC_FILES_CHKSUM = "\
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"

do_rootfs_extra_depends = ""
do_rootfs_extra_depends:omnect_uboot = "virtual/bootloader:do_deploy"
do_rootfs[depends] += "${do_rootfs_extra_depends}"

inherit omnect_initramfs

IMAGE_NAME = "${OMNECT_INITRAMFS_IMAGE_NAME}"

FLASH_MODE_X_PACKAGES = " \
    bmap-tools \
    dhcpcd \
    xz \
"

GRUB_SUPPORT_PACKAGES = " \
    grub-cfg \
    grub-editenv \
    grub-env \
"

RESIZE_DATA_PACKAGES = "\
    e2fsprogs-resize2fs \
    gptfdisk \
    growpart \
"

UBOOT_SUPPORT_PACKAGES = " \
    libubootenv \
    libubootenv-bin \
"

PACKAGE_INSTALL = "\
    bash \
    e2fsprogs-e2fsck \
    omnect-os-init \
    os-release \
    util-linux-sfdisk \
    util-linux-switch-root \
    ${ROOTFS_BOOTSTRAP_INSTALL} \
    ${VIRTUAL-RUNTIME_base-utils} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'resize-data', '${RESIZE_DATA_PACKAGES}', '', d)} \
"

PACKAGE_INSTALL:append:omnect_grub = " ${GRUB_SUPPORT_PACKAGES}"
PACKAGE_INSTALL:append:omnect_uboot = " ${UBOOT_SUPPORT_PACKAGES}"

ROOTFS_POSTPROCESS_COMMAND:append:omnect_uboot = " add_uboot_env;"
add_uboot_env() {
    install -m 644 -D ${DEPLOY_DIR_IMAGE}/uboot-env.bin $D/${sysconfdir}/omnect/uboot-env.bin
}


IMAGE_PREPROCESS_COMMAND:append = "add_fsck_vfat_support;"
add_fsck_vfat_support() {
    ln -sf /usr/sbin/fsck.fat ${IMAGE_ROOTFS}/sbin/
    ln -sf /usr/sbin/fsck.vfat ${IMAGE_ROOTFS}/sbin/
}

inherit ${@bb.utils.contains('DISTRO_FEATURES', 'flash-mode-2', 'omnect_user', '', d)}
