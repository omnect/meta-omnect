FILESEXTRAPATHS:prepend := "${LAYERDIR_ics_dm}/files:"

SRC_URI += "\
  file://iot-identity-service-certd.template.toml \
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

CARGO_BUILD_FLAGS .= " --no-default-features --features="systemd, azure-iot-sdk/device_client""

inherit aziot ics_dm_rust_azure-iot-sdk_deps systemd

do_install:append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/systemd/icsdm-device-service.service ${D}${systemd_system_unitdir}/icsdm-device-service.service
    install -m 0644 ${S}/systemd/icsdm-device-service.timer ${D}${systemd_system_unitdir}/icsdm-device-service.timer
    install -m 0644 ${S}/systemd/icsdm-device-factory-reset.service ${D}${systemd_system_unitdir}/icsdm-device-factory-reset.service
    install -m 0644 ${S}/systemd/icsdm-device-factory-reset.path ${D}${systemd_system_unitdir}/icsdm-device-factory-reset.path
    install -m 0644 ${S}/systemd/icsdm-device-reboot.service ${D}${systemd_system_unitdir}/icsdm-device-reboot.service
    install -m 0644 ${S}/systemd/icsdm-device-reboot.path ${D}${systemd_system_unitdir}/icsdm-device-reboot.path
    install -m 755 ${S}/script/factory_reset.sh ${D}${bindir}/

    # allow icsdm-device-service access to device_id secret created by manual provisioning
    install -m 0600 -o aziotks -g aziotks ${WORKDIR}/iot-identity-service-keyd.template.toml ${D}${sysconfdir}/aziot/keyd/config.d/icsdm-device-service.toml

    # allow icsdm-device-service provisioning via module identity
    install -m 0600 -o aziotid -g aziotid ${WORKDIR}/iot-identity-service-identityd.template.toml ${D}${sysconfdir}/aziot/identityd/config.d/icsdm-device-service.toml

    # only for testing provisioning as device identity:
    install -m 0600 -o aziotcs -g aziotcs ${WORKDIR}/iot-identity-service-certd.template.toml ${D}${sysconfdir}/aziot/certd/config.d/iot-hub-device-update.toml
    sed -i "s/^\[Service\]/\[Service\]\nEnvironment=RUST_LOG=debug/" ${D}${systemd_system_unitdir}/icsdm-device-service.service
}

pkg_postinst:${PN}() {
    sed -i "s/@@UID@@/$(id -u icsdm_device_service)/" $D${sysconfdir}/aziot/keyd/config.d/icsdm-device-service.toml
    sed -i -e "s/@@UID@@/$(id -u icsdm_device_service)/" \
        -e "s/@@NAME@@/icsdm-device-service/" \
        -e "s/@@IDENTITY@@/device/" \
        $D${sysconfdir}/aziot/identityd/config.d/icsdm-device-service.toml

    # only for testing provisioning as device identity:
    sed -i "s/@@UID@@/$(id -u icsdm_device_service)/" $D${sysconfdir}/aziot/certd/config.d/iot-hub-device-update.toml
}

SYSTEMD_SERVICE:${PN} = " \
    icsdm-device-service.service \
    icsdm-device-service.timer \
    icsdm-device-factory-reset.path \
    icsdm-device-reboot.path \
"

FILES:${PN} += "\
    ${systemd_system_unitdir}/icsdm-device-factory-reset.service \
    ${systemd_system_unitdir}/icsdm-device-reboot.service \
    ${bindir}/factory_reset.sh \
"

GROUPADD_PARAM:${PN} += " \
  -r icsdm_device_service; \
  -r disk; \
  -r adu; \
"

USERADD_PARAM:${PN} += "--no-create-home -r -s /bin/false -G aziotcs,aziotid,aziotks,disk,adu -g icsdm_device_service icsdm_device_service;"
