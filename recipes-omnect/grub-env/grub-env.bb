FILESEXTRAPATHS:prepend := "${LAYERDIR_omnect}/files/:"

# for usage in intramfs flash-mode only

#@ todo dual?
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "\
    file://grubenv \
"

do_install() {
	install -m 0644 -D ${WORKDIR}/grubenv ${D}${sysconfdir}/omnect/grubenv.in
}
