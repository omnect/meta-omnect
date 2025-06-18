inherit ${@bb.utils.contains('DISTRO_FEATURES', 'efi-secure-boot', 'user-key-store', '', d)}

fakeroot python sign() {
    import re

    if (d.expand('${TARGET_ARCH}') != 'x86_64') and (not re.match('i.86', d.expand('${TARGET_ARCH}'))):
        return

    if d.expand('${UEFI_SB}') != '1':
        return

    import shutil

    initramfs = d.expand('${IMGDEPLOYDIR}/${IMAGE_NAME}.${OMNECT_INITRAMFS_FSTYPE}')
    bb.note("initramfs: \"%s\"" % (initramfs))
    shutil.copy(initramfs, initramfs + '.unsigned')
    uks_bl_sign(initramfs, d)
}
IMAGE_POSTPROCESS_COMMAND:append = "${@bb.utils.contains('DISTRO_FEATURES', 'efi-secure-boot', 'check_deploy_keys;sign;', '', d)}"
