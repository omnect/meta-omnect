inherit useradd

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM_${PN} = " -r iotedge"
USERADD_PARAM_${PN} = "--no-create-home -r -s /bin/false -g iotedge iotedge"

do_install_append_rpi() {
  install -d ${D}/mnt/data/var/lib/iotedge
  chown iotedge:iotedge ${D}/mnt/data/var/lib/iotedge
}
FILES_${PN}_append = " /mnt/"
