SUMMARY = "ics-dm-os image"

LICENSE = "MIT | Apache-2.0"

LIC_FILES_CHKSUM = "\
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"

inherit core-image
inherit extrausers

# we need the initramfs bundled kernel before rootfs postprocessing
do_rootfs[depends] += "virtual/kernel:do_deploy"
do_rootfs[depends] += "ics-dm-os-initramfs:do_image_complete"

IMAGE_LINGUAS = "en-us"

IMAGE_BASENAME = "ics-dm-os"

IMAGE_NAME = "${DISTRO_NAME}_${DISTRO_VERSION}_${MACHINE}"

IMAGE_INSTALL = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'ics-dm-demo', ' enrollment', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'iotedge', ' iotedge-daemon iotedge-cli kernel-modules', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wifi-commissioning', ' wifi-commissioning-gatt-service', '', d)} \
    ${CORE_IMAGE_BASE_INSTALL} \
    iot-hub-device-update \
    packagegroup-core-ssh-dropbear \
    u-boot-fw-utils \
    ics-dm-base-files \
"

ICS_DM_DEVEL_TOOLS_DEFAULT = "\
    valgrind \
    ltrace \
    strace \
    gdbserver \
    htop \
    lsof \
    curl \
    tcpdump \
    ethtool \
    lshw \
    sysstat \
    ldd \
    parted \
    smartmontools \
    mmc-utils \
    sudo \
    coreutils \
    procps \
"

# check environment variable ICS_DM_DEVEL_TOOLS
def check_for_devel_tools(d):
    # use default list part of this recipe
    if d.getVar('ICS_DM_DEVEL_TOOLS', True) in [None, ""] : return "${ICS_DM_DEVEL_TOOLS_DEFAULT}"

    # use settings from environment
    return "${ICS_DM_DEVEL_TOOLS}"

IMAGE_INSTALL += "${@check_for_devel_tools(d)}"

# We don't want to add kernel and initramfs to
# IMAGE_BOOT_FILES to get it into rootfs, so we do it via post.
# If we add it to IMAGE_BOOT_FILES, wic would move it to the boot
# partition.
# By this postprocess handling both get installed to rootA and are therefore
# updatable via swupdate.
ROOTFS_POSTPROCESS_COMMAND_append = " add_kernel_and_initramfs;"
add_kernel_and_initramfs() {
    kernel=$(readlink -f ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${MACHINE}.bin)
    initramfs=$(readlink -f ${DEPLOY_DIR_IMAGE}/${ICS_DM_INITRAMFS_IMAGE_NAME}.${ICS_DM_INITRAMFS_FSTYPE})
    install -m 0644 ${kernel} $D/boot/
    install -m 0644 ${initramfs} $D/boot/
    ln -sf $(basename ${kernel}) $D/boot/${KERNEL_IMAGETYPE}.bin
    ln -sf $(basename ${initramfs}) $D/boot/initramfs.${ICS_DM_INITRAMFS_FSTYPE}
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

# add ics-dm user with password
EXTRA_USERS_PARAMS = "\
    useradd -p '${ICS_DM_USER_PWD_HASH}' ics-dm; \
"
