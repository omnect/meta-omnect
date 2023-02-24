FILESEXTRAPATHS:prepend := "${LAYERDIR_omnect}/files:"

SRC_URI += "\
  file://iot-identity-service-keyd.template.toml \
  file://iot-identity-service-identityd.template.toml \
"

PV .= "_${SRCPV}"

# we have to truncate ${PV}, it's to long for do_fetch
python() {
    pv = d.getVar('PV')
    pv = pv[:128]
    d.setVar('PV', pv)
}

# overwrite LICENSE and LIC_FILES_CHKSUM from cargo-bitbake generated recipe
LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://LICENSE-APACHE;md5=650e893673eb59696f3d4ee64f6d2357 \
    file://LICENSE-MIT;md5=afb814368d9110052a22e0da67f027d3 \
"

# used by pkg_config crate, in turn used by libdbus_sys crate
DEPENDS += "pkgconfig-native"

DEPENDS += "\
    azure-iot-sdk-c\
"
RDEPENDS:${PN} += "\
    aziot-identityd\
    ca-certificates\
"
inherit aziot omnect_rust_azure-iot-sdk_deps systemd

do_install:append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/systemd/iot-client-template-rs.service ${D}${systemd_system_unitdir}/iot-client-template-rs.service
    install -m 0644 ${S}/systemd/iot-client-template-rs.timer ${D}${systemd_system_unitdir}/iot-client-template-rs.timer

    # allow iot-client-template-rs access to device_id secret created by manual provisioning
    install -m 0600 -o aziotks -g aziotks ${WORKDIR}/iot-identity-service-keyd.template.toml ${D}${sysconfdir}/aziot/keyd/config.d/iot-client-template-rs.toml

    # allow iot-client-template-rs provisioning via module identity
    install -m 0600 -o aziotid -g aziotid ${WORKDIR}/iot-identity-service-identityd.template.toml ${D}${sysconfdir}/aziot/identityd/config.d/iot-client-template-rs.toml
}

pkg_postinst:${PN}() {
    sed -i "s/@@UID@@/$(id -u iot-client-rs)/"                                           $D${sysconfdir}/aziot/keyd/config.d/iot-client-template-rs.toml
    sed -i -e "s/@@UID@@/$(id -u iot-client-rs)/" -e "s/@@NAME@@/iot-client-template-rs/"  $D${sysconfdir}/aziot/identityd/config.d/iot-client-template-rs.toml
}

SYSTEMD_SERVICE:${PN} = "iot-client-template-rs.service iot-client-template-rs.timer"

GROUPADD_PARAM:${PN} += "-r iot-client-rs;"
USERADD_PARAM:${PN} += "--no-create-home -r -s /bin/false -G aziotcs,aziotid,aziotks -g iot-client-rs iot-client-rs;"
