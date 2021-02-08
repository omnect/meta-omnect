FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://0001-Add-path-exists"

inherit useradd

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM_${PN} += "; -r tpm"
GROUPMEMS_PARAM_${PN} = "-a iotedge -g tpm"

do_install_append() {
    install -d ${D}${sysconfdir}/iotedge
    chmod g+rw ${D}${sysconfdir}/iotedge/config.yaml

    install -d ${D}/lib/systemd/system
    patch ${D}/lib/systemd/system/iotedge.service ${WORKDIR}/0001-Add-path-exists
}