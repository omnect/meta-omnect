FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:${LAYERDIR_ics_dm}/files:"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=4ed9b57adc193f5cf3deae5b20552c06"

SRC_URI = " \
  git://github.com/azure/iot-hub-device-update.git;protocol=https;tag=0.8.0;nobranch=1 \
  file://iot-identity-service-keyd.template.toml \
  file://iot-identity-service-identityd.template.toml \
  file://eis-utils-cert-chain-buffer.patch \
  file://sd_notify.patch \
  file://rpipart_to_bootpart.patch \
  file://linux_platform_layer.patch \
  file://adu-agent.service \
  file://adu-agent.timer  \
  file://du-config.json \
  file://du-diagnostics-config.json \
  file://iot-hub-device-update.conf \
  ${@bb.utils.contains('EXTRA_IMAGE_FEATURES', 'ics-dm-debug', 'file://eis-utils-verbose-connection-string.patch', '', d)} \
"

S = "${WORKDIR}/git"

DEPENDS = " \
  azure-blob-storage-file-upload-utility \
  azure-iot-sdk-c \
  azure-sdk-for-cpp \
  boost \
  do-client-sdk \
  jq-native \
  libxml2 \
  systemd \
"

RDEPENDS:${PN} = " \
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
EXTRA_OECMAKE += "-DADUC_VERSION_FILE=/etc/sw-versions"
EXTRA_OECMAKE += "-DADUC_EXTENSIONS_INSTALL_FOLDER=${libdir}/adu/extensions"

EXTRA_OECMAKE += "-DADUC_DEVICEINFO_MANUFACTURER='${ADU_MANUFACTURER}'"
EXTRA_OECMAKE += "-DADUC_DEVICEINFO_MODEL='${ADU_MODEL}'"
EXTRA_OECMAKE += "-DADUC_DEVICEPROPERTIES_MANUFACTURER='${ADU_DEVICEPROPERTIES_MANUFACTURER}'"
EXTRA_OECMAKE += "-DADUC_DEVICEPROPERTIES_MODEL='${ADU_DEVICEPROPERTIES_MODEL}'"

#ics-dm adaptions (linux_platform_layer.patch)
EXTRA_OECMAKE += "-DADUC_STORAGE_PATH=/mnt/data/."

do_install:append() {
  # adu configuration
  install -d ${D}${sysconfdir}/adu
  jq  --arg adu_deviceproperties_manufacturer ${ADU_DEVICEPROPERTIES_MANUFACTURER} \
      --arg adu_deviceproperties_model ${ADU_DEVICEPROPERTIES_MODEL} \
      --arg adu_manufacturer ${ADU_MANUFACTURER} \
      --arg adu_model ${ADU_MODEL} \
      '.manufacturer = $adu_manufacturer |
      .model = $adu_model |
      .agents[].manufacturer = $adu_deviceproperties_manufacturer |
      .agents[].model = $adu_deviceproperties_model'\
      ${WORKDIR}/du-config.json > ${D}${sysconfdir}/adu/du-config.json
  chown adu:adu ${D}${sysconfdir}/adu/du-config.json
  chmod 0444 ${D}${sysconfdir}/adu/du-config.json

  install -m 0444 -o adu -g adu ${WORKDIR}/du-diagnostics-config.json ${D}${sysconfdir}/adu/

  # enable user adu to exec adu-shell
  chgrp adu ${D}${libdir}/adu/adu-shell
  # enable user adu to reboot with adu-shell
  chmod 04550 ${D}${libdir}/adu/adu-shell

  # create tmpfiles.d entry to (re)create dir + permissions
  install -m 0644 -D ${WORKDIR}/iot-hub-device-update.conf ${D}${libdir}/tmpfiles.d/iot-hub-device-update.conf

  # configure iot-hub-device-update as iot-identity-service client
  # allow adu client access to device_id secret created by manual provisioning
  install -m 0600 -o aziotks -g aziotks ${WORKDIR}/iot-identity-service-keyd.template.toml ${D}${sysconfdir}/aziot/keyd/config.d/iot-hub-device-update.toml

  # allow adu client provisioning via module identity
  install -m 0600 -o aziotid -g aziotid ${WORKDIR}/iot-identity-service-identityd.template.toml ${D}${sysconfdir}/aziot/identityd/config.d/iot-hub-device-update.toml

  # systemd
  install -d ${D}${systemd_system_unitdir}
  install -m 0644 ${WORKDIR}/adu-agent.service  ${D}${systemd_system_unitdir}/
  install -m 0644 ${WORKDIR}/adu-agent.timer    ${D}${systemd_system_unitdir}/
}

pkg_postinst:${PN}() {
  sed -i "s/@@UID@@/$(id -u adu)/" $D${sysconfdir}/aziot/keyd/config.d/iot-hub-device-update.toml
  sed -i -e "s/@@UID@@/$(id -u adu)/" -e "s/@@NAME@@/AducIotAgent/" $D${sysconfdir}/aziot/identityd/config.d/iot-hub-device-update.toml
}

SYSTEMD_SERVICE:${PN} = "adu-agent.service adu-agent.timer"
FILES:${PN} += " \
  ${libdir}/adu \
  ${libdir}/tmpfiles.d/iot-hub-device-update.conf \
  ${sysconfdir}/aziot/keyd/config.d/iot-hub-device-update.toml \
  ${sysconfdir}/aziot/identityd/config.d/iot-hub-device-update.toml \
  ${systemd_system_unitdir}/adu-agent.service \
  ${systemd_system_unitdir}/adu-agent.timer \
  "

GROUPADD_PARAM:${PN} += "-r adu;-r do;"
USERADD_PARAM:${PN} += "--no-create-home -r -s /bin/false -G disk,aziotcs,aziotid,aziotks,do -g adu adu;"
