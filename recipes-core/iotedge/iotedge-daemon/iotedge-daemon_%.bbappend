FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://ics-dm-systemd-service.patch;patchdir=${WORKDIR}/iotedge-1.0.9.4"

GROUPADD_PARAM_${PN} += "; -r tpm"
GROUPMEMS_PARAM_${PN} = "-a iotedge -g tpm"

do_install_append() {
    install -d ${D}${sysconfdir}/iotedge
    chmod g+rw ${D}${sysconfdir}/iotedge/config.yaml

    install -d ${D}/mnt/data/var/lib/iotedge
    chown iotedge:iotedge ${D}/mnt/data/var/lib/iotedge
}
FILES_${PN}_append = " /mnt/"
