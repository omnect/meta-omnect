DESCRIPTION = "This recipe installs utilities for handling LTE connections"

LICENSE = "MIT | Apache-2.0"

LIC_FILES_CHKSUM = "\
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"

SRC_URI = " \
	file://omnect-wwan.service \
	file://80-wwan.network \
	file://80-wwan.link \
	file://modem-connect.sh \
"

RDEPENDS:${PN} = "bash"

inherit systemd

S = "${WORKDIR}"

do_install() {
    install -d ${D}/${systemd_system_unitdir}
    install -d ${D}/${systemd_unitdir}/network
    install -m 0644 ${WORKDIR}/omnect-wwan.service ${D}/${systemd_system_unitdir}/
    install -m 0644 ${WORKDIR}/80-wwan.network     ${D}/${systemd_unitdir}/network/
    install -m 0644 ${WORKDIR}/80-wwan.link        ${D}/${systemd_unitdir}/network/

    install -d ${D}/usr/bin
    install -m 755 ${WORKDIR}/modem-connect.sh     ${D}/usr/bin/modem-connect.sh
}

SYSTEMD_SERVICE:${PN} = "omnect-wwan.service"

FILES:${PN} = "\
        {systemd_system_unitdir}/omnect-wwan.service \
	${systemd_unitdir}/network/80-wwan.network \
	${systemd_unitdir}/network/80-wwan.link \
	usr/bin/modem-connect.sh \
"

