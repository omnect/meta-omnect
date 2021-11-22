FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:${THISDIR}/../../files:"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE.md;md5=95a70c9e1af3b97d8bde6f7435d535a8"

SRC_URI = " \
  git://github.com/azure/iot-hub-device-update.git;protocol=https;branch=release/2021-q2;tag=0.7.0 \
  file://iot-identity-service-keyd.template.toml \
  file://iot-identity-service-identityd.template.toml \
  file://linux_platform_layer.patch \
  file://rpipart_to_bootpart.patch \
  file://eis-utils-cert-chain-buffer.patch \
  file://eis-utils-set-GatewayHostName.patch  \
  ${@bb.utils.contains('EXTRA_IMAGE_FEATURES', 'ics-dm-debug', 'file://eis-utils-verbose-connection-string.patch', '', d)} \
"

S = "${WORKDIR}/git"

DEPENDS = " \
  azure-iot-sdk-c \
  boost \
  do-client-sdk \
"

RDEPENDS_${PN} = " \
  adu-pub-key \
  bash \
  do-client \
  iot-identity-service \
  swupdate \
"

inherit aziot cmake systemd

EXTRA_OECMAKE += "-DADUC_LOG_FOLDER=/var/log/aduc-logs"
EXTRA_OECMAKE += "-DADUC_CONTENT_HANDLERS=microsoft/swupdate"
EXTRA_OECMAKE += "-DADUC_INSTALL_DAEMON=OFF"
EXTRA_OECMAKE += "-DADUC_PLATFORM_LAYER=linux"
EXTRA_OECMAKE += "-DADUC_PROVISION_WITH_EIS=ON"
EXTRA_OECMAKE += "-DADUC_VERSION_FILE=/etc/sw-versions"

EXTRA_OECMAKE += "-DADUC_DEVICEINFO_MANUFACTURER='${ADU_MANUFACTURER}'"
EXTRA_OECMAKE += "-DADUC_DEVICEINFO_MODEL='${ADU_MODEL}'"
EXTRA_OECMAKE += "-DADUC_DEVICEPROPERTIES_MANUFACTURER='${ADU_DEVICEPROPERTIES_MANUFACTURER}'"
EXTRA_OECMAKE += "-DADUC_DEVICEPROPERTIES_MODEL='${ADU_DEVICEPROPERTIES_MODEL}'"

#ics-dm adaptions (linux_platform_layer.patch)
EXTRA_OECMAKE += "-DADUC_STORAGE_PATH=/mnt/data/."

do_install_append() {
  install -d ${D}${systemd_system_unitdir}
  install -m 0644 ${S}/daemon/adu-agent.service ${D}${systemd_system_unitdir}

  install -d ${D}${sysconfdir}/adu
  touch ${D}${sysconfdir}/adu/adu-conf.txt
  chown adu:adu ${D}${sysconfdir}/adu/adu-conf.txt
  chmod g+w ${D}${sysconfdir}/adu/adu-conf.txt

  #enable user adu to exec adu-shell
  chgrp adu ${D}${libdir}/adu/adu-shell
  #enable user adu to reboot with adu-shell
  chmod +s ${D}${libdir}/adu/adu-shell

  # create tmpfiles.d entry to (re)create dir + permissions
  install -d ${D}${libdir}/tmpfiles.d
  echo "d /var/log/aduc-logs 1755 adu adu -"    >> ${D}${libdir}/tmpfiles.d/iot-hub-device-update.conf
  echo "d /mnt/data/var/lib/adu 0755 adu adu -" >> ${D}${libdir}/tmpfiles.d/iot-hub-device-update.conf
  echo "z /etc/adu 0775 adu adu -"              >> ${D}${libdir}/tmpfiles.d/iot-hub-device-update.conf
  echo "z /etc/adu/adu-conf.txt 0660 adu adu -" >> ${D}${libdir}/tmpfiles.d/iot-hub-device-update.conf

  install -d -o adu -g adu ${D}/mnt/data/var/lib/adu

  # configure iot-hub-device-update as iot-identity-service client
  # allow adu client access to device_id secret created by manual provisioning
  install -m 0600 -o aziotks -g aziotks ${WORKDIR}/iot-identity-service-keyd.template.toml ${D}${sysconfdir}/aziot/keyd/config.d/iot-hub-device-update.toml

  # allow adu client provisioning via module identity
  install -m 0600 -o aziotid -g aziotid ${WORKDIR}/iot-identity-service-identityd.template.toml ${D}${sysconfdir}/aziot/identityd/config.d/iot-hub-device-update.toml

  # systemd
  sed -i -e 's/^After=\(.*\)$/After=\1 systemd-tmpfiles-setup.service aziot-identityd.service/' \
         -e 's/^Wants=\(.*\)$/Wants=\1 aziot-identityd.service/' ${D}${systemd_system_unitdir}/adu-agent.service
  # fix hard device path in adu-swupdate.sh (odroid-c2 needs this when booting from sdcard)
  sed -i 's#/dev/mmcblk0p#${ROOT_DEV_P}#' ${D}${libdir}/adu/adu-swupdate.sh
}

do_install_append_rpi() {
  sed -i 's/^After=\(.*\)$/After=\1 time-sync.target/' ${D}${systemd_system_unitdir}/adu-agent.service
}

pkg_postinst_${PN}() {
  sed -i "s/@@UID@@/$(id -u adu)/" $D${sysconfdir}/aziot/keyd/config.d/iot-hub-device-update.toml
  sed -i -e "s/@@UID@@/$(id -u adu)/" -e "s/@@NAME@@/AducIotAgent/" $D${sysconfdir}/aziot/identityd/config.d/iot-hub-device-update.toml
}

SYSTEMD_SERVICE_${PN} = "adu-agent.service"
FILES_${PN} += " \
  ${libdir}/adu \
  ${libdir}/tmpfiles.d/iot-hub-device-update.conf \
  ${sysconfdir}/aziot/keyd/config.d/iot-hub-device-update.toml \
  ${sysconfdir}/aziot/identityd/config.d/iot-hub-device-update.toml \
  ${systemd_system_unitdir}/adu-agent.service \
  /mnt/data/var/lib/adu \
  "

GROUPADD_PARAM_${PN} += "-r adu;"
USERADD_PARAM_${PN} += "--no-create-home -r -s /bin/false -G disk,aziotcs,aziotid,aziotks -g adu adu;"
