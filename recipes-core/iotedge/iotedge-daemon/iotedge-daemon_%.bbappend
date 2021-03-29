FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://ics-dm-systemd-service.patch;patchdir=${WORKDIR}/iotedge-1.0.9.4"

GROUPADD_PARAM_${PN} += "; -r tpm"
GROUPMEMS_PARAM_${PN} = "-a iotedge -g tpm"

do_install_append() {
    install -d ${D}${sysconfdir}/iotedge
    chmod g+rw ${D}${sysconfdir}/iotedge/config.yaml

    install -d ${D}/mnt/data/var/lib/iotedge
    chown iotedge:iotedge ${D}/mnt/data/var/lib/iotedge
    install -d ${D}${libdir}/tmpfiles.d
    echo "d /mnt/data/var/lib/iotedge 0755 iotedge iotedge -"  >> ${D}${libdir}/tmpfiles.d/iotedge.conf

}
FILES_${PN}_append = " \
    ${libdir}/tmpfiles.d/iotedge.conf \
    /mnt/data/var/lib/iotedge \
    "
