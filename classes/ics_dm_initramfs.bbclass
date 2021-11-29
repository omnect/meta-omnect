#
#  ics-dm initramfs image
#

inherit image

IMAGE_FSTYPES = "${ICS_DM_INITRAMFS_FSTYPE}"

# reset IMAGE_FEATURES var for initramfs
IMAGE_FEATURES = ""
IMAGE_LINGUAS = ""
KERNELDEPMODDEPEND = ""
IMAGE_NAME_SUFFIX = ""

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
