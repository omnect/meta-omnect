DESCRIPTION = "omnecte-first-boot is a service executed on first boot of device (or after factory-reset)"

LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
"

inherit systemd

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://omnect-first-boot.service \
    file://omnect_first_boot.sh \
"

RDEPENDS:${PN} += "bash"

do_install() {
    install -m 0644 -D ${WORKDIR}/omnect-first-boot.service ${D}${systemd_system_unitdir}/omnect-first-boot.service
    install -m 0755 -D ${WORKDIR}/omnect_first_boot.sh ${D}${bindir}/omnect_first_boot.sh
}

SYSTEMD_SERVICE:${PN} = " \
    omnect-first-boot.service \
"
FILES:${PN} = "\
    ${bindir}/omnect_first_boot.sh \
    ${systemd_system_unitdir}/omnect-first-boot.service \
"
