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
# check_deploy_keys handles UEFI_SB/MOK/etc. but not BOOT, so it never sets GPG_PATH or
# imports the SecureBootCore signing key. Run check_boot_public_key first (same postprocess
# chain, so its GPG_PATH setVar persists) or boot_sign gets --homedir None and fails.
IMAGE_POSTPROCESS_COMMAND:append = "${@bb.utils.contains('DISTRO_FEATURES', 'efi-secure-boot', ';check_deploy_keys;check_boot_public_key;sign', '', d)}"
