do_install_append(){
  sed -i 's/^\[Socket\]/\[Socket\]\nSocketUser=adu\nSocketGroup=adu/' ${D}${systemd_system_unitdir}/swupdate.socket
}

inherit useradd
USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM_${PN} = "-r adu"
