FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "\
    file://tpm.rules \
"

do_install() {
	install -d ${D}${sysconfdir}/udev/rules.d
	install -m 0644 ${WORKDIR}/tpm.rules ${D}${sysconfdir}/udev/rules.d/
}

inherit useradd

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM_${PN} = "-r tpm"
USERADD_PARAM_${PN} = "--no-create-home -r -s /bin/false -g tpm tpm"
