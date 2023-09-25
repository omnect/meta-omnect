FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# for usage in intramfs only

LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"

SRC_URI = "\
    file://grub.cfg.in \
"

do_install() {
    sed -i "s/@@APPEND@@/${APPEND}/g" ${WORKDIR}/grub.cfg.in
	install -m 0644 -D ${WORKDIR}/grub.cfg.in ${D}${sysconfdir}/omnect/grub.cfg.in
}
