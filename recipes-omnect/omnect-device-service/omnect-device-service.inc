FILESEXTRAPATHS:prepend := "${LAYERDIR_omnect}/files:${THISDIR}/${PN}:"

SRC_URI += "\
  file://iot-identity-service-keyd.template.toml \
  file://iot-identity-service-identityd.template.toml \
  file://omnect-device-service.tmpfilesd \
"

PV .= "+${SRCPV}"
CVE_PRODUCT = "omnect:${PN}"

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
    file://LICENSE-MIT;md5=6340606a960b1965e521043f21f8d1bb \
"

DEPENDS += "\
    azure-iot-sdk-c \
    pkgconfig-native \
"

RDEPENDS:${PN} += "\
    aziot-identityd\
    ca-certificates\
    polkit \
    sudo \
"
RDEPENDS:${PN}:append:omnect_grub = " grub-editenv"
RDEPENDS:${PN}:append:omnect_uboot = " u-boot-fw-utils"

inherit omnect-device-service omnect_rust_azure-iot-sdk_deps systemd

CARGO_BUILD_FLAGS:append:omnect_grub = " --features=bootloader_grub"
CARGO_BUILD_FLAGS:append:omnect_uboot = " --features=bootloader_uboot"

do_install:append() {
    install -m 0644 -D ${S}/systemd/omnect-device-service.service ${D}${systemd_system_unitdir}/omnect-device-service.service
    sed -i -e 's/^After=\(.*\)$/After=\1 systemd-tmpfiles-setup.service/' ${D}${systemd_system_unitdir}/omnect-device-service.service
    install -m 0644 -D ${S}/systemd/omnect-device-service.timer ${D}${systemd_system_unitdir}/omnect-device-service.timer
    install -m 0644 -D ${S}/polkit/omnect-device-service.rules ${D}${datadir}/polkit-1/rules.d/omnect-device-service.rules
    install -m 0640 -D ${S}/sudo/omnect-device-service ${D}${sysconfdir}/sudoers.d/omnect-device-service

    # allow omnect-device-service access to device_id secret created by manual provisioning
    install -m 0600 -o aziotks -g aziotks ${WORKDIR}/iot-identity-service-keyd.template.toml ${D}${sysconfdir}/aziot/keyd/config.d/omnect-device-service.toml

    # allow omnect-device-service provisioning via module identity
    install -m 0600 -o aziotid -g aziotid ${WORKDIR}/iot-identity-service-identityd.template.toml ${D}${sysconfdir}/aziot/identityd/config.d/omnect-device-service.toml

    # create tmpfiles.d entry to (re)create dir + permissions
    install -m 0644 -D ${WORKDIR}/omnect-device-service.tmpfilesd ${D}${libdir}/tmpfiles.d/omnect-device-service.conf
}

do_install:append:omnect_grub() {
    install -m 0640 -D ${S}/sudo/omnect-device-service-grub ${D}${sysconfdir}/sudoers.d/omnect-device-service-bootloader-env
}

do_install:append:omnect_uboot() {
    install -m 0640 -D ${S}/sudo/omnect-device-service-uboot ${D}${sysconfdir}/sudoers.d/omnect-device-service-bootloader-env
}

pkg_postinst:${PN}() {
    sed -i    "s/@@UID@@/$(id -u omnect_device_service)/"                                           $D${sysconfdir}/aziot/keyd/config.d/omnect-device-service.toml
    sed -i -e "s/@@UID@@/$(id -u omnect_device_service)/" -e "s/@@NAME@@/omnect-device-service/"    $D${sysconfdir}/aziot/identityd/config.d/omnect-device-service.toml
}

SYSTEMD_SERVICE:${PN} = " \
    omnect-device-service.service \
    omnect-device-service.timer \
"

FILES:${PN} += "\
    ${datadir}/polkit-1/rules.d/omnect-device-service.rules \
    ${libdir}/tmpfiles.d/omnect-device-service.conf \
    ${sysconfdir}/sudoers.d/omnect-device-service \
    ${sysconfdir}/sudoers.d/omnect-device-service-bootloader-env \
"

# prevent stripping symbols
INHIBIT_PACKAGE_STRIP = "1"
