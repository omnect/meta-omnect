SUMMARY = "ics-dm swupdate image"

LICENSE = "MIT | Apache-2.0"

LIC_FILES_CHKSUM = "\
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"

inherit core-image

IMAGE_BASENAME = "ics-dm-os"

IMAGE_FEATURES += " read-only-rootfs"

IMAGE_NAME = "${DISTRO_NAME}_${DISTRO_VERSION}_${MACHINE}"

IMAGE_INSTALL = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'ics-dm-demo', ' enrollment', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'iotedge', ' iotedge-daemon iotedge-cli kernel-modules', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', ' expand-data', '', d)} \
    ${CORE_IMAGE_BASE_INSTALL} \
    iot-hub-device-update \
    packagegroup-core-ssh-dropbear \
    u-boot-fw-utils \
"


# we don't want add ${KERNEL_IMAGETYPE}-initramfs-${MACHINE}.bin to
# IMAGE_BOOT_FILES to get it into rootfs so we do it via post.
ROOTFS_POSTPROCESS_COMMAND_append = " add_initramfs;"
add_initramfs() {
    initramfs=$(readlink -f ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-initramfs-${MACHINE}.bin)
    install -m 0644 ${initramfs} $D/boot/
    ln -sf $(basename ${initramfs}) $D/boot/${KERNEL_IMAGETYPE}-initramfs.bin
}
