FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += " file://fstab.raspberrypi"

do_install_append_rpi() {
  install -m 0644 ${WORKDIR}/fstab.raspberrypi ${D}/etc/fstab
}
