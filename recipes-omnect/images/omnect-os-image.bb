SUMMARY = "omnect-os image"

LICENSE = "MIT | Apache-2.0"

LIC_FILES_CHKSUM = "\
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"
# we need the bootloader version in the *testdata.json artifact
def omnect_create_bootloader_version(d):
    path = d.getVar('DEPLOY_DIR_IMAGE') + '/bootloader_version'
    str = ""
    try:
        str = open(path, 'r').read().split()[0]
    except:
        pass
    return str

BOOTLOADER_VERSION = "${@omnect_create_bootloader_version(d)}"

inherit core-image

# we need the initramfs bundled kernel before rootfs postprocessing
do_rootfs[depends] += "virtual/kernel:do_deploy"
do_rootfs[depends] += "omnect-os-initramfs:do_image_complete"

# we add boot.scr to the image on condition
do_rootfs_extra_depends = ""
do_rootfs_extra_depends:omnect_uboot = "u-boot-scr:do_deploy"
do_rootfs[depends] += "${do_rootfs_extra_depends}"
IMAGE_BOOT_FILES:append:omnect_uboot = " boot.scr"
IMAGE_BOOT_FILES += "${@bb.utils.contains('UBOOT_FDT_LOAD', '1', 'fdt-load.scr', '', d)}"

# native openssl tool required
do_rootfs[depends] += "openssl-native:do_populate_sysroot"

IMAGE_LINGUAS = "en-us"

IMAGE_BASENAME = "omnect-os"

IMAGE_NAME = "${DISTRO_NAME}_${DISTRO_VERSION}_${MACHINE}"

IMAGE_INSTALL = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'iotedge', ' aziot-edged iotedge kernel-modules', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', ' systemd-bash-completion', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wifi-commissioning', ' wifi-commissioning-gatt-service', '', d)} \
    ${CORE_IMAGE_BASE_INSTALL} \
    bootloader-env \
    coreutils \
    iot-hub-device-update \
    iptables \
    kmod \
    omnect-base-files \
    omnect-first-boot \
    packagegroup-core-ssh-openssh \
    sudo \
    systemd-analyze \
    e2fsprogs-tune2fs \
    jq \
    procps \
    ${@oe.utils.conditional('OMNECT_RELEASE_IMAGE', '1', '', '${OMNECT_DEVEL_TOOLS}', d)} \
"

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

# systemd getty terminals get enabled after do_rootfs and/or at runtime if not explicitly masked;
# for a release image we explicitly disable them by masking
IMAGE_PREPROCESS_COMMAND:append = "${@bb.utils.contains('OMNECT_RELEASE_IMAGE', '1', 'disable_getty;', '', d)}"
disable_getty() {
    for i in ${IMAGE_ROOTFS}${sysconfdir}/systemd/system/getty.target.wants/getty@*.service; do
        rm ${i}
        ln -sf /dev/null ${IMAGE_ROOTFS}${sysconfdir}/systemd/system/$(basename ${i})
    done
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

# warn if debugfs gets generated and IMAGE_INSTALL doesn't include gdbserver
python () {
    debugfs = d.getVar('IMAGE_GEN_DEBUGFS') == "1"
    if debugfs and 'gdbserver' not in d.getVar('IMAGE_INSTALL').split():
        bb.warn("debugfs gets generated but the image doesn't contain the gdb server")
}

inherit omnect_user

inherit logging

# positive test for packages, i.e. check if installed
check_installed_packages() {
    local manifest="$1"
    local pkglist="$2"
    local error_not_installed="$3"
    local ret=0
    for p in $pkglist; do
        if ! grep -q "^$p " "$manifest"; then
            [ "$error_not_installed" = 1 ] \
               && bberror "Required TOOL not installed in image: $p"
            ret=1
         fi
    done
    return $ret
}

# post processing function checking for default tools
verify_image_tools() {
    local ret=0
    local manifest="${IMAGE_MANIFEST}"
    local release="${OMNECT_RELEASE_IMAGE}"
    local tools="${OMNECT_DEVEL_TOOLS}"
    local relhint=""

    # something to be checked at all?
    [ "$tools" ] || return 0

    [ "$release" = 1 ] && relhint="release "
    bbnote "NOTE: checking for OMNECT_DEVEL_TOOLS in ${relhint}image ..."
    bbnote "[$tools]"

    set -- ${tools}
    if [ $# -gt 0 ]; then
        if [ "$release" = 1 ]; then
            if check_installed_packages "$manifest" "$tools" 0; then
                bbwarn 'OMNECT_DEVEL_TOOLS are contained in image!'
                bbwarn "[$tools]"
                ret=1
            fi
        else
            if ! check_installed_packages "$manifest" "$tools" 1; then
                bbwarn 'OMNECT_DEVEL_TOOLS are missing in image!'
                bbwarn "[$tools]"
                ret=1
            fi
        fi
    fi
    if [ $ret != 0 ]; then
        bberror 'TOOLS check failed!'
    fi
    return $ret
}

IMAGE_POSTPROCESS_COMMAND += "verify_image_tools;"
