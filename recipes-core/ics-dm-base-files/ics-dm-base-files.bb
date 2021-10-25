SUMMARY = "ICS DM Base Files"
DESCRIPTION = "Provide ICS DM Base Files."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "\                                                                                         
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
"

SRC_URI = "\
    file://etc/sudoers.d/001_ics-dm \
"

FILES_${PN} = "\
    /etc/sudoers.d/001_ics-dm \
"

do_install() {
    install -d ${D}/etc/sudoers.d/
    install -m 0644 ${WORKDIR}/etc/sudoers.d/001_ics-dm ${D}/etc/sudoers.d/
}
