#TODO repo currently has no license info
LICENSE = "CLOSED"

SRC_URI = "git://git@github.com/ICS-DeviceManagement/iot-module-template.git;protocol=ssh;branch=main"
SRCREV = "${AUTOREV}"

S = "${WORKDIR}/git"

DEPENDS = "azure-iot-sdk-c"
RDEPENDS_${PN} = "ca-certificates iot-identity-service"

inherit cmake features_check overwrite_src_uri systemd useradd

EXTRA_OECMAKE += "-DINSTALL_DIR=${bindir}"
EXTRA_OECMAKE += "-DSERVICE_INSTALL_DIR=${systemd_system_unitdir}"

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM_${PN} = " \
  -r aziotid; \
  -r aziotks; \
  -r iotmodule; \
"
USERADD_PARAM_${PN} = "--no-create-home -r -s /bin/false -G aziotid,aziotks -g iotmodule iotmodule"

SYSTEMD_SERVICE_${PN} = "iot-module-template.service"
REQUIRED_DISTRO_FEATURES = "systemd"

pkg_postinst_${PN}() {
  # allow iot-module-template access to device_id secret created by manual provisioning
  echo "[[principal]]" >> ${D}${sysconfdir}/aziot/keyd/config.d/iot-module-template.toml
  echo "uid = $(id -u iotmodule)" >> ${D}${sysconfdir}/aziot/keyd/config.d/iot-module-template.toml
  echo "keys = [\"device_id\"]" >> ${D}${sysconfdir}/aziot/keyd/config.d/iot-module-template.toml
  chmod 0600 ${D}${sysconfdir}/aziot/keyd/config.d/iot-module-template.toml
  chown aziotks:aziotks ${D}${sysconfdir}/aziot/keyd/config.d/iot-module-template.toml

  # allow adu client provisioning via module identity
  echo "[[principal]]" >> ${D}${sysconfdir}/aziot/identityd/config.d/iot-module-template.toml
  echo "uid = $(id -u iotmodule)" >> ${D}${sysconfdir}/aziot/identityd/config.d/iot-module-template.toml
  echo "name = \"AducIotAgent\"" >> ${D}${sysconfdir}/aziot/identityd/config.d/iot-module-template.toml
  echo "idtype = [\"module\"]" >> ${D}${sysconfdir}/aziot/identityd/config.d/iot-module-template.toml
  chmod 0600 ${D}${sysconfdir}/aziot/identityd/config.d/iot-module-template.toml
  chown aziotid:aziotid ${D}${sysconfdir}/aziot/identityd/config.d/iot-module-template.toml
}