DESCRIPTION = "Oneshot service that applies /etc/omnect/modem-config.json to the modem"

# file-only recipe: sources land in ${UNPACKDIR} now which is by default
# ${WORKDIR}/sources
S = "${UNPACKDIR}"

LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
"

inherit systemd

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://omnect-modem-config.service \
    file://omnect-modem-config.sh \
"

# jq parses the config files, mmcli applies the settings
RDEPENDS:${PN} += "jq modemmanager"

do_install() {
    install -m 0644 -D ${UNPACKDIR}/omnect-modem-config.service ${D}${systemd_system_unitdir}/omnect-modem-config.service
    install -m 0755 -D ${UNPACKDIR}/omnect-modem-config.sh ${D}${bindir}/omnect-modem-config.sh
}

SYSTEMD_SERVICE:${PN} = "omnect-modem-config.service"

FILES:${PN} = "\
    ${bindir}/omnect-modem-config.sh \
    ${systemd_system_unitdir}/omnect-modem-config.service \
"
