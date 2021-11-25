LICENSE = "MIT | Apache-2.0"

LIC_FILES_CHKSUM = "\
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"
inherit image

# reset IMAGE_FEATURES var for initramfs
IMAGE_FEATURES = ""
IMAGE_LINGUAS = ""
KERNELDEPMODDEPEND = ""
IMAGE_NAME_SUFFIX = ""

IMAGE_FSTYPES = "${ICS_DM_INITRAMFS_FSTYPE}"
IMAGE_NAME = "${ICS_DM_INITRAMFS_IMAGE_NAME}"

RESIZE_DATA_PACKAGES = "\
    e2fsprogs-e2fsck \
    e2fsprogs-resize2fs \
    libubootenv \
    libubootenv-bin \
    parted \
"

PACKAGE_INSTALL = "\
    base-passwd \
    ics-dm-os-initramfs-scripts \
    initramfs-framework-base \
    initramfs-module-udev \
    udev \
    ${RESIZE_DATA_PACKAGES} \
    ${ROOTFS_BOOTSTRAP_INSTALL} \
    ${VIRTUAL-RUNTIME_base-utils} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'resize-data', '${RESIZE_DATA_PACKAGES}', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'initramfs-flash-mode', 'dhcp-client dropbear bmap-tools xz', '', d)} \
"

# don't use rootfs module initramfs-framework-base
BAD_RECOMMENDATIONS += "initramfs-module-rootfs"

# enable creating sstate cache for image
SSTATE_SKIP_CREATION:task-image-complete = "0"
SSTATE_SKIP_CREATION:task-image-qa = "0"
inherit nopackages
python sstate_report_unihash() {
    report_unihash = getattr(bb.parse.siggen, 'report_unihash', None)

    if report_unihash:
        ss = sstate_state_fromvars(d)
        if ss['task'] == 'image_complete':
            os.environ['PSEUDO_DISABLED'] = '1'
        report_unihash(os.getcwd(), ss['task'], d)
}


inherit ${@bb.utils.contains('DISTRO_FEATURES', 'initramfs-flash-mode', 'ics_dm_user', '', d)}
