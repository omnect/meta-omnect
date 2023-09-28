FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"

SRC_URI = "\
    file://grub.cfg.in \
"

do_compile() {
    sed -e "s/@@APPEND@@/${APPEND}/g" \
        -e "s#@@OMNECT_ROOT_DEVICE@@#${OMNECT_ROOT_DEVICE}#g" \
        ${WORKDIR}/grub.cfg.in > ${WORKDIR}/grub.cfg
}

# do install used when installing into initramfs (used by flash-mode-1)
do_install() {
	install -m 0644 -D ${WORKDIR}/grub.cfg ${D}${sysconfdir}/omnect/grub.cfg
}

# do deploy used for omnect-os-image do_wic step
do_deploy() {
    install -m 0644 -D ${WORKDIR}/grub.cfg ${DEPLOY_DIR_IMAGE}/grub.cfg
}

inherit deploy
addtask do_deploy after do_compile before do_build
