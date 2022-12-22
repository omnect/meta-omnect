FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# for usage in intramfs only

#@ todo dual?
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "\
    file://grub.cfg.in \
"

do_install() {
	install -m 0644 -D ${WORKDIR}/grub.cfg.in ${D}${sysconfdir}/omnect/grub.cfg.in
}
