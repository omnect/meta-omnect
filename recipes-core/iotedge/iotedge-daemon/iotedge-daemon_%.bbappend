FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://0001-Add-path-exists.patch;patchdir=${WORKDIR}/iotedge-1.0.9.4"

inherit useradd

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM_${PN} += "; -r tpm"
GROUPMEMS_PARAM_${PN} = "-a iotedge -g tpm"

do_install_append() {
    install -d ${D}${sysconfdir}/iotedge
    chmod g+rw ${D}${sysconfdir}/iotedge/config.yaml

    install -d ${D}/mnt/data/var/lib/iotedge
    chown iotedge:iotedge ${D}/mnt/data/var/lib/iotedge
}
FILES_${PN}_append = " /mnt/"