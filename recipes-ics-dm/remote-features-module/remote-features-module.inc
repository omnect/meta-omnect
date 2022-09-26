FILESEXTRAPATHS:prepend := "${LAYERDIR_ics_dm}/files:"

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

# used by pkg_config crate, in turn used by libdbus_sys crate
DEPENDS += "pkgconfig-native"

# overwrite LICENSE and LIC_FILES_CHKSUM from cargo-bitbake generated recipe
LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://LICENSE-APACHE;md5=650e893673eb59696f3d4ee64f6d2357 \
    file://LICENSE-MIT;md5=6340606a960b1965e521043f21f8d1bb \
"

DEPENDS += "\
    azure-iot-sdk-c\
"
RDEPENDS:${PN} += "\
    ca-certificates\
    iot-identity-service\
"
inherit aziot ics_dm_rust_azure-iot-sdk_deps systemd

do_install:append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/systemd/remote-features-module.service ${D}${systemd_system_unitdir}/remote-features-module.service
    install -m 0644 ${S}/systemd/remote-features-module.timer ${D}${systemd_system_unitdir}/remote-features-module.timer
    install -m 0644 ${S}/systemd/remote-features-factory-reset.service ${D}${systemd_system_unitdir}/remote-features-factory-reset.service
    install -m 0644 ${S}/systemd/remote-features-factory-reset.path ${D}${systemd_system_unitdir}/remote-features-factory-reset.path
    install -m 0644 ${S}/systemd/remote-features-reboot.service ${D}${systemd_system_unitdir}/remote-features-reboot.service
    install -m 0644 ${S}/systemd/remote-features-reboot.path ${D}${systemd_system_unitdir}/remote-features-reboot.path
    install -m 755 ${S}/script/factory_reset.sh ${D}${bindir}/

    # allow remote-features-module access to device_id secret created by manual provisioning
    install -m 0600 -o aziotks -g aziotks ${WORKDIR}/iot-identity-service-keyd.template.toml ${D}${sysconfdir}/aziot/keyd/config.d/remote-features-module.toml

    # allow remote-features-module provisioning via module identity
    install -m 0600 -o aziotid -g aziotid ${WORKDIR}/iot-identity-service-identityd.template.toml ${D}${sysconfdir}/aziot/identityd/config.d/remote-features-module.toml
}

pkg_postinst:${PN}() {
    sed -i "s/@@UID@@/$(id -u remote-features)/"                                           $D${sysconfdir}/aziot/keyd/config.d/remote-features-module.toml
    sed -i -e "s/@@UID@@/$(id -u remote-features)/" -e "s/@@NAME@@/remote-features-module/"    $D${sysconfdir}/aziot/identityd/config.d/remote-features-module.toml
}

SYSTEMD_SERVICE:${PN} = "remote-features-module.service remote-features-module.timer remote-features-factory-reset.path"

FILES:${PN} += "\
    ${systemd_system_unitdir}/remote-features-factory-reset.service \
    ${systemd_system_unitdir}/remote-features-reboot.service \
    ${bindir}/factory_reset.sh \
"

GROUPADD_PARAM:${PN} += " \
  -r remote_features; \
  -r disk; \
  -r adu; \
"

USERADD_PARAM:${PN} += "--no-create-home -r -s /bin/false -G aziotcs,aziotid,aziotks,disk,adu -g remote_features remote_features;"
