FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:${LAYERDIR_omnect}/files/:"

PROVIDES:omnect_grub = "virtual/bootloader"

inherit omnect_bootloader

SRC_URI += "\
    file://omnect.inc \
    file://grubenv \
"

do_compile:append:class-target() {
    mv ${WORKDIR}/omnect.inc ${WORKDIR}/boot-menu.inc
    [ ${OMNECT_RELEASE_IMAGE} -eq 1 ] && sed -ie "s/^timeout=\(.\)/timeout=0/g" ${WORKDIR}/grub-efi.cfg

    grub-script-check ${WORKDIR}/grub-efi.cfg
    grub-script-check ${WORKDIR}/efi-secure-boot.inc
    grub-script-check ${WORKDIR}/boot-menu.inc
}

do_install:append() {
    # we need to replace the standard grubenv file with our own one, because
    # we use a bigger file
    install -m 0644 ${WORKDIR}/grubenv ${D}${EFI_BOOT_PATH}/grubenv
}

GRUB_BUILDIN:append = " echo sleep"
