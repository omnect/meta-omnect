LICENSE = "MIT | Apache-2.0"

LIC_FILES_CHKSUM = "\
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"
inherit core-image

# reset IMAGE_FEATURES var for initramfs
IMAGE_FEATURES = ""
IMAGE_LINGUAS = ""

IMAGE_FSTYPES = "${INITRAMFS_FSTYPES}"

PACKAGE_INSTALL = "\
    base-passwd \
    ics-dm-os-initramfs-rootfs-mount \
    initramfs-framework-base \
    initramfs-module-udev \
    udev \
    ${ROOTFS_BOOTSTRAP_INSTALL} \
    ${VIRTUAL-RUNTIME_base-utils} \
"
IMAGE_NAME = "${DISTRO_NAME}_${DISTRO_VERSION}_${MACHINE}-initramfs"

# don't uses rootfs module initamfs-framwork-base
BAD_RECOMMENDATIONS += "initramfs-module-rootfs"
