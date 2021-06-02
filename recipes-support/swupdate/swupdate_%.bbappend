FILESEXTRAPATHS_append := "${THISDIR}/${PN}:"

PACKAGECONFIG_CONFARGS = ""

inherit useradd

do_install_append() {
  if [ -z "${HW_REV}" ];then bb_error "HW_REV not set" ;exit 1; fi
  if [ -z "${MACHINE}" ];then bb_error "MACHINE not set";exit 1; fi
  if [ -z "${SOFTWARE_NAME}" ];then bb_error "SOFTWARE_NAME not set"; exit 1; fi
  if [ -z "${SOFTWARE_VERSION}" ];then bb_error "SOFTWARE_VERSION not set"; exit 1; fi

  echo "${MACHINE} ${HW_REV}" >> ${D}/${sysconfdir}/hwrevision
  echo "${SOFTWARE_NAME} ${SOFTWARE_VERSION}" >> ${D}/${sysconfdir}/sw-versions

  sed -i 's/^\[Socket\]/\[Socket\]\nSocketUser=adu\nSocketGroup=adu/' ${D}${systemd_system_unitdir}/swupdate.socket
}

FILES_${PN} += " \
    ${sysconfdir}/hwrevision \
    ${sysconfdir}/sw-versions \
"

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM_${PN} = "-r adu"
