FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# file-only recipe: sources land in ${UNPACKDIR} now which is by default
# ${WORKDIR}/sources
S = "${UNPACKDIR}"

LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = " \
	file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
	file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
"

SRC_URI = "\
    file://10-cryptodev.rules \
"

do_install() {
	install -d ${D}${sysconfdir}/udev/rules.d
	install -m 0644 ${UNPACKDIR}/10-cryptodev.rules ${D}${sysconfdir}/udev/rules.d/
}
