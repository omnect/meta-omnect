FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PROVIDES:omnect_grub = "virtual/bootloader"

inherit omnect_bootloader

SRC_URI += "file://omnect.inc.in"

do_compile:append:class-target() {
    sed -e "s/@@APPEND@@/${APPEND}/g" \
        ${WORKDIR}/omnect.inc.in > ${WORKDIR}/boot-menu.inc

    [ ${OMNECT_RELEASE_IMAGE} -eq 1 ] && sed -ie "s/^timeout=\(.\)/timeout=0/g" ${WORKDIR}/grub-efi.cfg

    grub-script-check ${WORKDIR}/boot-menu.inc
    grub-script-check ${WORKDIR}/grub-efi.cfg
}

GRUB_BUILDIN:append = " echo"