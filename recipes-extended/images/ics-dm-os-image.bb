SUMMARY = "ics-dm swupdate image"

LICENSE = "MIT | Apache-2.0"

LIC_FILES_CHKSUM = "\
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"

inherit core-image

# we need the initramfs bundled kernel before rootfs postprocessing
do_rootfs[depends] += "virtual/kernel:do_deploy"

IMAGE_LINGUAS = "en-us"

IMAGE_BASENAME = "ics-dm-os"

IMAGE_NAME = "${DISTRO_NAME}_${DISTRO_VERSION}_${MACHINE}"

IMAGE_INSTALL = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'ics-dm-demo', ' enrollment', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'iotedge', ' iotedge-daemon iotedge-cli kernel-modules', '', d)} \
    ${CORE_IMAGE_BASE_INSTALL} \
    iot-hub-device-update \
    packagegroup-core-ssh-dropbear \
    u-boot-fw-utils \
"

# We don't want add ${KERNEL_IMAGETYPE}-initramfs-${MACHINE}.bin to
# IMAGE_BOOT_FILES to get it into rootfs, so we do it via post.
# If we add it to IMAGE_BOOT_FILES wic would move it to the boot
# partition.
# By this postprocess handling the bundled initramfs kernel gets installed
# to rootA and is therefore updatable via swupdate.
ROOTFS_POSTPROCESS_COMMAND_append = " add_initramfs;"
add_initramfs() {
    initramfs=$(readlink -f ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-initramfs-${MACHINE}.bin)
    install -m 0644 ${initramfs} $D/boot/
    ln -sf $(basename ${initramfs}) $D/boot/${KERNEL_IMAGETYPE}-initramfs.bin
}


# Poky checks at creation time of rootfs and even later when creating the
# image that '/etc/machine-id' is available when using systemd. The idea
# behind seems to be that they can bind mount a volatile machine-id on
# systems with readonly rootfs.
# Unfortunately this breaks systemds "ConditionFirstBoot" check, were a
# precondition is, that '/etc/machine-id' does not exists.
# (https://github.com/systemd/systemd/issues/8268)
#
# Since we have a writeable 'etc' overlay before systemd starts we don't
# need a preexisting empty '/etc/machine-id' and thus delete it as late
# as possible:
IMAGE_PREPROCESS_COMMAND_append = " remove_machine_id; reproducible_final_image_task;"
remove_machine_id() {
    rm -f ${IMAGE_ROOTFS}${sysconfdir}/machine-id
}
