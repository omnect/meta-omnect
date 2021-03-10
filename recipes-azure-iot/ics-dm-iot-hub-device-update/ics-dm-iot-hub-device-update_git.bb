FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE.md;md5=95a70c9e1af3b97d8bde6f7435d535a8"

SRC_URI = " \
  git://git@github.com/ICS-DeviceManagement/iot-hub-device-update.git;protocol=ssh;branch=0.6.0-ics-dm \
  "
SRCREV = "${AUTOREV}"

python () {
    src_uri = d.getVar('ICS_DM_IOT_HUB_DEVICE_UPDATE_SRC_URI')
    if src_uri:
      d.setVar('SRC_URI', src_uri)
}

S = "${WORKDIR}/git"

DEPENDS = "boost azure-iot-sdk-c do-client-sdk"
RDEPENDS_${PN} = "bash adu-pub-key do-client swupdate"
RPROVIDES_${PN} = "virtual/iot-hub-device-update"

inherit cmake systemd features_check useradd

EXTRA_OECMAKE += "-DADUC_LOG_FOLDER=/mnt/data/aduc-logs"
EXTRA_OECMAKE += "-DADUC_CONTENT_HANDLERS=microsoft/swupdate"
EXTRA_OECMAKE += "-DADUC_INSTALL_DAEMON=OFF"
EXTRA_OECMAKE += "-DADUC_PLATFORM_LAYER=linux"
EXTRA_OECMAKE += "-DADUC_VERSION_FILE=/etc/sw-versions"

EXTRA_OECMAKE += "-DADUC_DEVICEINFO_MANUFACTURER='${ADU_MANUFACTURER}'"
EXTRA_OECMAKE += "-DADUC_DEVICEINFO_MODEL='${ADU_MODEL}'"
EXTRA_OECMAKE += "-DADUC_DEVICEPROPERTIES_MANUFACTURER='${ADU_DEVICEPROPERTIES_MANUFACTURER}'"
EXTRA_OECMAKE += "-DADUC_DEVICEPROPERTIES_MODEL='${ADU_DEVICEPROPERTIES_MODEL}'"

EXTRA_OECMAKE += "-DDPS_ENDPOINT=${DPS_ENDPOINT}"
EXTRA_OECMAKE += "-DDPS_SCOPE_ID=${DPS_SCOPE_ID}"

do_install_append() {
  install -d ${D}${systemd_system_unitdir}
  install -m 0644 ${S}/daemon/adu-agent.service ${D}${systemd_system_unitdir}

  install -d ${D}${sysconfdir}/adu
  echo "connection-string="           >> ${D}${sysconfdir}/adu/adu-conf.txt
  echo "dps-mode=tpm"                 >> ${D}${sysconfdir}/adu/adu-conf.txt
  echo "dps-endpoint=${DPS_ENDPOINT}" >> ${D}${sysconfdir}/adu/adu-conf.txt
  echo "dps-scope-id=${DPS_SCOPE_ID}" >> ${D}${sysconfdir}/adu/adu-conf.txt

  install -d ${D}/mnt/data/aduc-logs
  if ! ${@bb.utils.to_boolean(d.getVar('VOLATILE_LOG_DIR'))}; then
    install -d ${D}/var/log
    lnr ${D}/mnt/data/aduc-logs ${D}/var/log/aduc
  fi
}

do_install_append_rpi() {
    sed -i 's/^After=\(.*\)$/After=\1 dev-tpmrm0.device mnt-etc.mount var-lib.mount/' ${D}${systemd_system_unitdir}/adu-agent.service
}

SYSTEMD_SERVICE_${PN} = "adu-agent.service"
FILES_${PN} += " \
  ${libdir}/adu \
  ${systemd_system_unitdir}/adu-agent.service \
  /mnt/data/aduc-logs \
  ${@ '' if bb.utils.to_boolean(d.getVar('VOLATILE_LOG_DIR')) else '/var/log/aduc'} \
  "
REQUIRED_DISTRO_FEATURES = "systemd"

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM_${PN} = "adu"
