FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PROVIDES:omnect_grub = "virtual/bootloader"

inherit omnect_bootloader

SRC_URI += "file://omnect.inc"

do_compile:append:class-target() {
    [ ${OMNECT_RELEASE_IMAGE} -eq 1 ] && sed -ie "s/^timeout=\(.\)/timeout=0/g" ${WORKDIR}/grub-efi.cfg

    grub-script-check ${WORKDIR}/grub-efi.cfg
    grub-script-check ${WORKDIR}/efi-secure-boot.inc
    grub-script-check ${WORKDIR}/boot-menu.inc
}

GRUB_BUILDIN:append = " echo sleep"
