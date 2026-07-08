DESCRIPTION = "Oneshot that starts/configures wifi commissioning from /etc/omnect/device_caps.json"

LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
"

inherit systemd

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://omnect-wifi-commissioning.service \
    file://omnect-wifi-commissioning-start \
"

RDEPENDS:${PN} += "wpa-supplicant"

do_install() {
    install -m 0644 -D ${WORKDIR}/omnect-wifi-commissioning.service ${D}${systemd_system_unitdir}/omnect-wifi-commissioning.service
    install -m 0755 -D ${WORKDIR}/omnect-wifi-commissioning-start ${D}${bindir}/omnect-wifi-commissioning-start
}

SYSTEMD_SERVICE:${PN} = "omnect-wifi-commissioning.service"

FILES:${PN} = "\
    ${bindir}/omnect-wifi-commissioning-start \
    ${systemd_system_unitdir}/omnect-wifi-commissioning.service \
"
