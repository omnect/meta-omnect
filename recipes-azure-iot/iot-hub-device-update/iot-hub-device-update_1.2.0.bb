FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:${LAYERDIR_omnect}/files:"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=4ed9b57adc193f5cf3deae5b20552c06"

SRC_URI = " \
  git://github.com/azure/iot-hub-device-update.git;protocol=https;tag=1.2.0;nobranch=1 \
  file://deviceupdate-agent.service \
  file://deviceupdate-agent.timer \
  file://du-config.json \
  file://du-diagnostics-config.json \
  file://iot-hub-device-update.tmpfilesd \
  file://iot-identity-service-keyd.template.toml \
  file://iot-identity-service-identityd.template.toml \
  file://omnect_1.2.0.patch \
"
SRC_URI:append:omnect_uboot = " file://swupdate_handler_v2_u-boot.sh"
SRC_URI:append:omnect_grub = " file://swupdate_handler_v2_grub.sh"

PV .= "+${SRCPV}"

S = "${WORKDIR}/git"

DEPENDS = " \
  azure-iot-sdk-c \
  boost \
  do-client-sdk \
  jq-native \
  libxml2 \
  systemd \
"

RDEPENDS:${PN} = " \
  aziot-identityd \
  bash \
  do-client \
  swupdate \
"

inherit aziot cmake systemd

EXTRA_OECMAKE += "-DADUC_LOG_FOLDER=/var/log/aduc-logs"
EXTRA_OECMAKE += "-DADUC_INSTALL_DAEMON=OFF"
EXTRA_OECMAKE += "-DADUC_PLATFORM_LAYER=linux"
EXTRA_OECMAKE += "-DADUC_VERSION_FILE=/etc/sw-versions"
EXTRA_OECMAKE += "-DADUC_EXTENSIONS_INSTALL_FOLDER=${libdir}/adu/extensions"
EXTRA_OECMAKE += "-DADUC_STEP_HANDLERS:STRING=microsoft/swupdate_v2,omnect/swupdate_consent_v1"
EXTRA_OECMAKE += "-DADUC_DEVICEINFO_MANUFACTURER='${OMNECT_ADU_MANUFACTURER}'"
EXTRA_OECMAKE += "-DADUC_DEVICEINFO_MODEL='${OMNECT_ADU_MODEL}'"
EXTRA_OECMAKE += "-DADUC_DEVICEPROPERTIES_MANUFACTURER='${OMNECT_ADU_DEVICEPROPERTIES_MANUFACTURER}'"
EXTRA_OECMAKE += "-DADUC_DEVICEPROPERTIES_MODEL='${OMNECT_ADU_DEVICEPROPERTIES_MODEL}'"

# omnect adaptions (linux_platform_layer.patch)
EXTRA_OECMAKE += "-DADUC_STORAGE_PATH=/mnt/data/."

do_install:append() {
  # adu configuration
  install -d ${D}${sysconfdir}/adu
  jq  --arg adu_deviceproperties_manufacturer "${OMNECT_ADU_DEVICEPROPERTIES_MANUFACTURER}" \
      --arg adu_deviceproperties_model "${OMNECT_ADU_DEVICEPROPERTIES_MODEL}" \
      --arg adu_deviceproperties_compatibility_id "${OMNECT_ADU_DEVICEPROPERTIES_COMPATIBILITY_ID}" \
      --arg adu_manufacturer "${OMNECT_ADU_MANUFACTURER}" \
      --arg adu_model "${OMNECT_ADU_MODEL}" \
      '.manufacturer = $adu_manufacturer |
      .model = $adu_model |
      .agents[].manufacturer = $adu_deviceproperties_manufacturer |
      .agents[].model = $adu_deviceproperties_model |
      .agents[].additionalDeviceProperties.compatibilityid = $adu_deviceproperties_compatibility_id'\
      ${WORKDIR}/du-config.json > ${D}${sysconfdir}/adu/du-config.json
  chown adu:adu ${D}${sysconfdir}/adu/du-config.json
  chmod 0444 ${D}${sysconfdir}/adu/du-config.json

  install -m 0444 -o adu -g adu ${WORKDIR}/du-diagnostics-config.json ${D}${sysconfdir}/adu/

  # enable user adu to exec adu-shell
  chgrp adu ${D}${bindir}/adu-shell
  # enable user adu to reboot with adu-shell
  chmod 04550 ${D}${bindir}/adu-shell

  # create tmpfiles.d entry to (re)create dir + permissions
  install -m 0644 -D ${WORKDIR}/iot-hub-device-update.tmpfilesd ${D}${libdir}/tmpfiles.d/iot-hub-device-update.conf

  # configure iot-hub-device-update as iot-identity-service client
  # allow adu client access to device_id secret created by manual provisioning
  install -m 0600 -o aziotks -g aziotks ${WORKDIR}/iot-identity-service-keyd.template.toml ${D}${sysconfdir}/aziot/keyd/config.d/iot-hub-device-update.toml

  # allow adu client provisioning via module identity
  install -m 0600 -o aziotid -g aziotid ${WORKDIR}/iot-identity-service-identityd.template.toml ${D}${sysconfdir}/aziot/identityd/config.d/iot-hub-device-update.toml

  # systemd
  install -d ${D}${systemd_system_unitdir}
  install -m 0644 ${WORKDIR}/deviceupdate-agent.service  ${D}${systemd_system_unitdir}/
  install -m 0644 ${WORKDIR}/deviceupdate-agent.timer    ${D}${systemd_system_unitdir}/

  # user_consent
  install -d ${D}${sysconfdir}/omnect/consent
  install -m 0660 -o adu -g adu ${S}/src/extensions/step_handlers/swupdate_consent_handler/files/consent_conf.json ${D}${sysconfdir}/omnect/consent/
  install -m 0660 -o adu -g adu ${S}/src/extensions/step_handlers/swupdate_consent_handler/files/history_consent.json ${D}${sysconfdir}/omnect/consent/
  install -m 0660 -o adu -g adu ${S}/src/extensions/step_handlers/swupdate_consent_handler/files/request_consent.json ${D}${sysconfdir}/omnect/consent/
  install -d ${D}${sysconfdir}/omnect/consent/swupdate
  install -m 0660 -o adu -g adu ${S}/src/extensions/step_handlers/swupdate_consent_handler/files/user_consent.json ${D}${sysconfdir}/omnect/consent/swupdate/

  # delete adu-swupdate.sh
  rm ${D}${bindir}/adu-swupdate.sh
}

do_install:append:omnect_grub() {
  # install the swupdate_v2 script only for devel images
  if ${@bb.utils.contains('OMNECT_RELEASE_IMAGE', '0', 'true', 'false', d)}; then
    install -d ${D}${libdir}/swupdate
    install -m 0755 ${WORKDIR}/swupdate_handler_v2_grub.sh ${D}${libdir}/swupdate/omnect-swupdate.sh
  fi
}

do_install:append:omnect_uboot() {
  # install the swupdate_v2 script only for devel images
  if ${@bb.utils.contains('OMNECT_RELEASE_IMAGE', '0', 'true', 'false', d)}; then
    install -d ${D}${libdir}/swupdate
    install -m 0755 ${WORKDIR}/swupdate_handler_v2_u-boot.sh ${D}${libdir}/swupdate/omnect-swupdate.sh
  fi
}

pkg_postinst:${PN}() {
  sed -i "s/@@UID@@/$(id -u adu)/" $D${sysconfdir}/aziot/keyd/config.d/iot-hub-device-update.toml
  sed -i -e "s/@@UID@@/$(id -u adu)/" -e "s/@@NAME@@/AducIotAgent/" $D${sysconfdir}/aziot/identityd/config.d/iot-hub-device-update.toml
}

SYSTEMD_SERVICE:${PN} = " \
  deviceupdate-agent.service \
  deviceupdate-agent.timer \
"

FILES:${PN} += " \
  ${@bb.utils.contains('OMNECT_RELEASE_IMAGE', '1', '', '${libdir}/swupdate/omnect-swupdate.sh', d)} \
  ${libdir}/adu \
  ${libdir}/tmpfiles.d/iot-hub-device-update.conf \
  ${sysconfdir}/aziot/keyd/config.d/iot-hub-device-update.toml \
  ${sysconfdir}/aziot/identityd/config.d/iot-hub-device-update.toml \
  ${systemd_system_unitdir}/deviceupdate-agent.service \
  ${systemd_system_unitdir}/deviceupdate-agent.timer \
  ${sysconfdir}/omnect/consent/consent_conf.json \
  ${sysconfdir}/omnect/consent/history_consent.json \
  ${sysconfdir}/omnect/consent/request_consent.json \
  ${sysconfdir}/omnect/consent/swupdate/user_consent.json \
  "

GROUPADD_PARAM:${PN} += " \
  -r adu; \
  -r do; \
"
USERADD_PARAM:${PN} += "--no-create-home -r -s /bin/false -G aziotcs,aziotid,aziotks,disk,do -g adu adu;"
