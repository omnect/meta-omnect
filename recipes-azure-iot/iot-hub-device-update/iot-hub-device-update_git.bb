FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE.md;md5=95a70c9e1af3b97d8bde6f7435d535a8"

SRC_URI = " \
  git://github.com/azure/iot-hub-device-update.git;protocol=https;branch=main;tag=0.6.0 \
  file://fix-linking.patch \
  "

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

do_install_append() {
  install -d ${D}${systemd_system_unitdir}
  install -m 0644 ${S}/daemon/adu-agent.service ${D}${systemd_system_unitdir}

  install -d ${D}${sysconfdir}/adu
  echo "connection_string=" >> ${D}${sysconfdir}/adu/adu-conf.txt
  chown adu:adu ${D}${sysconfdir}/adu/adu-conf.txt
  chmod g+w ${D}${sysconfdir}/adu/adu-conf.txt

  #enable user adu to exec adu-shell
  chgrp adu ${D}${libdir}/adu/adu-shell
  #enable user adu to reboot with adu-shell
  chmod +s ${D}${libdir}/adu/adu-shell

  install -d -m 1775 ${D}/mnt/data/aduc-logs
  chown adu:adu ${D}/mnt/data/aduc-logs
  if ! ${@bb.utils.to_boolean(d.getVar('VOLATILE_LOG_DIR'))}; then
    install -d ${D}/var/log
    lnr ${D}/mnt/data/aduc-logs ${D}/var/log/aduc
  fi

  install -d ${D}/mnt/data/var/lib/adu
  chown adu:adu ${D}/mnt/data/var/lib/adu

  sed -i 's/^After=\(.*\)$/After=\1 mnt-etc.mount var-lib.mount/' ${D}${systemd_system_unitdir}/adu-agent.service
  sed -i 's#^ExecStart=\(.*\)$#ExecStart=\1\nEnvironment=\"SSL_CERT_DIR=/etc/ssl/certs/\"#' ${D}${systemd_system_unitdir}/adu-agent.service
}

do_install_append_rpi() {
  sed -i 's/^After=\(.*\)$/After=\1 time-sync.target/' ${D}${systemd_system_unitdir}/adu-agent.service
}

SYSTEMD_SERVICE_${PN} = "adu-agent.service"
FILES_${PN} += " \
  ${libdir}/adu \
  ${systemd_system_unitdir}/adu-agent.service \
  /mnt/data/aduc-logs \
  /mnt/data/var/lib/adu \
  ${@ '' if bb.utils.to_boolean(d.getVar('VOLATILE_LOG_DIR')) else '/var/log/aduc'} \
  "
REQUIRED_DISTRO_FEATURES = "systemd"

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM_${PN} = "-r adu"
USERADD_PARAM_${PN} = "--no-create-home -r -s /bin/false -G disk -g adu adu"
