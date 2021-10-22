FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

do_install_append () {
    install -d -D ${D}${sysconfdir}/sudoers.d/
    install -m 0644 ${WORKDIR}/001_ics-dm ${D}/${sysconfdir}/sudoers.d/
}

SRC_URI += "\
    file://001_ics-dm \
"

FILES_${PN} += "\
    ${sysconfdir}/sudoers.d/ \
    ${sysconfdir}/sudoers.d/001_ics-dm \
"
