FILESEXTRAPATHS:prepend := "${LAYERDIR_omnect}/files:${THISDIR}/${PN}:"

SRC_URI += "\
  file://iot-identity-service-keyd.template.toml \
  file://iot-identity-service-identityd.template.toml \
  file://omnect-device-service.conf \
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
    aziot-identityd\
    ca-certificates\
"
inherit omnect-device-service omnect_rust_azure-iot-sdk_deps systemd

do_install:append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/systemd/omnect-device-service.service ${D}${systemd_system_unitdir}/omnect-device-service.service
    install -m 0644 ${S}/systemd/omnect-device-service.timer ${D}${systemd_system_unitdir}/omnect-device-service.timer
    install -m 0644 ${S}/systemd/omnect-device-authorized_keys.service ${D}${systemd_system_unitdir}/omnect-device-authorized_keys.service
    install -m 0644 ${S}/systemd/omnect-device-authorized_keys.path ${D}${systemd_system_unitdir}/omnect-device-authorized_keys.path
    install -m 0644 ${S}/systemd/omnect-device-factory-reset.service ${D}${systemd_system_unitdir}/omnect-device-factory-reset.service
    install -m 0644 ${S}/systemd/omnect-device-factory-reset.path ${D}${systemd_system_unitdir}/omnect-device-factory-reset.path
    install -m 0644 ${S}/systemd/omnect-device-reboot.service ${D}${systemd_system_unitdir}/omnect-device-reboot.service
    install -m 0644 ${S}/systemd/omnect-device-reboot.path ${D}${systemd_system_unitdir}/omnect-device-reboot.path
    install -m 0644 ${S}/systemd/omnect-update-finalization.service ${D}${systemd_system_unitdir}/omnect-update-finalization.service
    install -m 0644 ${S}/systemd/omnect-update-finalization.path ${D}${systemd_system_unitdir}/omnect-update-finalization.path
    install -m 755 ${S}/script/factory_reset.sh ${D}${bindir}/

    # allow omnect-device-service access to device_id secret created by manual provisioning
    install -m 0600 -o aziotks -g aziotks ${WORKDIR}/iot-identity-service-keyd.template.toml ${D}${sysconfdir}/aziot/keyd/config.d/omnect-device-service.toml

    # allow omnect-device-service provisioning via module identity
    install -m 0600 -o aziotid -g aziotid ${WORKDIR}/iot-identity-service-identityd.template.toml ${D}${sysconfdir}/aziot/identityd/config.d/omnect-device-service.toml

    # create tmpfiles.d entry to (re)create dir + permissions
    install -m 0644 -D ${WORKDIR}/omnect-device-service.conf ${D}${libdir}/tmpfiles.d/omnect-device-service.conf
}

pkg_postinst:${PN}() {
    sed -i "s/@@UID@@/$(id -u omnect_device_service)/"                                           $D${sysconfdir}/aziot/keyd/config.d/omnect-device-service.toml
    sed -i -e "s/@@UID@@/$(id -u omnect_device_service)/" -e "s/@@NAME@@/omnect-device-service/"    $D${sysconfdir}/aziot/identityd/config.d/omnect-device-service.toml
}

SYSTEMD_SERVICE:${PN} = " \
    omnect-device-service.service \
    omnect-device-service.timer \
    omnect-device-authorized_keys.path \
    omnect-device-factory-reset.path \
    omnect-device-reboot.path \
    omnect-update-finalization.path \
"

FILES:${PN} += "\
    ${bindir}/factory_reset.sh \
    ${libdir}/tmpfiles.d/omnect-device-service.conf \
    ${systemd_system_unitdir}/omnect-device-authorized_keys.service \
    ${systemd_system_unitdir}/omnect-device-factory-reset.service \
    ${systemd_system_unitdir}/omnect-device-reboot.service \
    ${systemd_system_unitdir}/omnect-update-finalization.service \
"
