SUMMARY = "omnect-os image"

LICENSE = "MIT | Apache-2.0"

LIC_FILES_CHKSUM = "\
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"

inherit core-image

# we need the initramfs bundled kernel before rootfs postprocessing
do_rootfs[depends] += "virtual/kernel:do_deploy"
do_rootfs[depends] += "omnect-os-initramfs:do_image_complete"

# we add boot.scr to the image
do_rootfs[depends] += "u-boot-scr:do_deploy"
IMAGE_BOOT_FILES += "boot.scr"
IMAGE_BOOT_FILES += "${@bb.utils.contains('UBOOT_FDT_LOAD', '1', 'fdt-load.scr', '', d)}"

# native openssl tool required
do_rootfs[depends] += "openssl-native:do_populate_sysroot"

IMAGE_LINGUAS = "en-us"

IMAGE_BASENAME = "omnect-os"

IMAGE_NAME = "${DISTRO_NAME}_${DISTRO_VERSION}_${MACHINE}"

IMAGE_INSTALL = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'enrollment', ' enrollment', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'iotedge', ' aziot-edged iotedge kernel-modules', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', ' systemd-bash-completion', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wifi-commissioning', ' wifi-commissioning-gatt-service', '', d)} \
    ${CORE_IMAGE_BASE_INSTALL} \
    coreutils \
    omnect-base-files \
    iot-hub-device-update \
    packagegroup-core-ssh-dropbear \
    procps \
    sudo \
    kmod \
    u-boot-fw-utils \
"

# check environment variable OMNECT_DEVEL_TOOLS
def check_for_devel_tools(d):
    # use default list part of this recipe
    if d.getVar('OMNECT_DEVEL_TOOLS', True) in [None, ""] : return "${OMNECT_DEVEL_TOOLS_DEFAULT}"

    # use settings from environment
    return "${OMNECT_DEVEL_TOOLS}"

IMAGE_INSTALL += "${@check_for_devel_tools(d)}"

# We don't want to add initramfs to
# IMAGE_BOOT_FILES to get it into rootfs, so we do it via post.
# If we add it to IMAGE_BOOT_FILES, wic would move it to the boot
# partition.
# By this postprocess handling it gets installed to rootA and is therefore
# updatable via swupdate.
ROOTFS_POSTPROCESS_COMMAND:append = " add_kernel_and_initramfs;"
add_kernel_and_initramfs() {
    initramfs=$(readlink -f ${DEPLOY_DIR_IMAGE}/${OMNECT_INITRAMFS_IMAGE_NAME}.${OMNECT_INITRAMFS_FSTYPE})
    install -m 0644 ${initramfs} $D/boot/
    ln -sf ${KERNEL_IMAGETYPE} $D/boot/${KERNEL_IMAGETYPE}.bin
    ln -sf $(basename ${initramfs}) $D/boot/initramfs.${OMNECT_INITRAMFS_FSTYPE}
}

# setup omnect specific sysctl configuration (see systemd-sysctl.service)
ROOTFS_POSTPROCESS_COMMAND:append = " omnect_setup_sysctl_config;"
omnect_setup_sysctl_config() {
    echo "vm.panic_on_oom = ${OMNECT_VM_PANIC_ON_OOM}" >${IMAGE_ROOTFS}${sysconfdir}/sysctl.d/omnect.conf
}

ROOTFS_POSTPROCESS_COMMAND:append = " omnect_create_uboot_env_ff_img;"
omnect_create_uboot_env_ff_img() {
    dd if=/dev/zero bs=1024 count=${OMNECT_PART_SIZE_UBOOT_ENV} | tr "\000" "\377" >${DEPLOY_DIR_IMAGE}/omnect_uboot_env_ff.img
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
# also we delete fstab, since mounting filesystems is handled in initramfs
IMAGE_PREPROCESS_COMMAND:append = " remove_unwanted_files; adapt_cert_store; default_shell_bash; reproducible_final_image_task;"
remove_unwanted_files() {
    rm -f ${IMAGE_ROOTFS}${sysconfdir}/machine-id
    rm -f ${IMAGE_ROOTFS}${sysconfdir}/fstab
}
adapt_cert_store() {
    sed -i 's#^LOCALCERTSDIR=\(.*\)$#LOCALCERTSDIR=/mnt/cert/ca#' ${IMAGE_ROOTFS}${sbindir}/update-ca-certificates
}
# to enable bash-completion when using `sudo su`
default_shell_bash() {
    sed -i 's#/bin/sh$#/bin/bash#g' ${IMAGE_ROOTFS}${sysconfdir}/passwd
}


inherit omnect_user
