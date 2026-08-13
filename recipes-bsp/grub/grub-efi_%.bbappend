FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:${LAYERDIR_omnect}/files/:"

PROVIDES:omnect_grub = "virtual/bootloader"

inherit omnect_bootloader

SRC_URI += "\
    file://omnect.inc.in \
    file://grubenv \
"

do_compile:append:class-target() {
    sed -e "s/@@OMNECT_APPEND_1ST_BOOT@@/${OMNECT_APPEND_1ST_BOOT}/g" \
        ${WORKDIR}/omnect.inc.in > ${WORKDIR}/boot-menu.inc
    [ ${OMNECT_RELEASE_IMAGE} -eq 1 ] && sed -ie "s/^timeout=\(.\)/timeout=0/g" ${WORKDIR}/grub-efi.cfg

    grub-script-check ${WORKDIR}/grub-efi.cfg
    grub-script-check ${WORKDIR}/efi-secure-boot.inc
    grub-script-check ${WORKDIR}/boot-menu.inc
}

do_install:append:class-target() {
    # we need to replace the standard grubenv file with our own one, because
    # we use a bigger file
    install -m 0644 ${WORKDIR}/grubenv ${D}${EFI_BOOT_PATH}/grubenv
}

GRUB_BUILDIN:append = " echo sleep probe"
