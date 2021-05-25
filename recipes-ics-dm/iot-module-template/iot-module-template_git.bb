# TODO licensing is complicated. Furthermore the repo currently has no
# license files for LIC_FILES_CHKSUM.
# Without ais/eis the license would be
# LICENSE = "MIT | Apache-2.0"
# With eis/ais we have to mention that these eis/ais sources are MIT only.
# Or we package eis/ais in an independent library with MIT license.
#LICENSE = "MIT & MIT | Apache-2.0"
#LIC_FILES_CHKSUM =
LICENSE = "CLOSED"

FILESEXTRAPATHS_prepend := "${THISDIR}/../../files:"

# TODO change to https uri when public
REPO_URI = "git://git@github.com/ICS-DeviceManagement/iot-module-template.git;protocol=ssh;branch=main;"
SRC_URI = " \
  ${REPO_URI} \
  file://iot-identity-service-keyd.template.toml \
  file://iot-identity-service-identityd.template.toml \
"
SRCREV = "${AUTOREV}"

S = "${WORKDIR}/git"

DEPENDS = "azure-iot-sdk-c"
RDEPENDS_${PN} = "ca-certificates iot-identity-service"

inherit aziot cmake overwrite_src_uri systemd

EXTRA_OECMAKE += "-DINSTALL_DIR=${bindir}"
EXTRA_OECMAKE += "-DSERVICE_INSTALL_DIR=${systemd_system_unitdir}"

do_install_append() {
  # allow iot-module-template access to device_id secret created by manual provisioning
  install -m 0600 -o aziotks -g aziotks ${WORKDIR}/iot-identity-service-keyd.template.toml ${D}${sysconfdir}/aziot/keyd/config.d/iot-module-template.toml

  # allow adu client provisioning via module identity
  install -m 0600 -o aziotid -g aziotid ${WORKDIR}/iot-identity-service-identityd.template.toml ${D}${sysconfdir}/aziot/identityd/config.d/iot-module-template.toml
}

pkg_postinst_${PN}() {
  sed -i "s/@@UID@@/$(id -u iotmodule)/" $D${sysconfdir}/aziot/keyd/config.d/iot-module-template.toml
  sed -i -e "s/@@UID@@/$(id -u iotmodule)/" -e "s/@@NAME@@/iot-module-template/" $D${sysconfdir}/aziot/identityd/config.d/iot-module-template.toml
}

SYSTEMD_SERVICE_${PN} = "iot-module-template.service"

GROUPADD_PARAM_${PN} += "-r iotmodule;"
USERADD_PARAM_${PN} += "--no-create-home -r -s /bin/false -G aziotid,aziotks -g iotmodule iotmodule;"
