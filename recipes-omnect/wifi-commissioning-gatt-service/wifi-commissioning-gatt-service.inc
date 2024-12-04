
# overwrite LICENSE and LIC_FILES_CHKSUM from cargo-bitbake generated recipe
LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://LICENSE-APACHE;md5=5382c4e117e2483c68e932fd10c4fd48 \
    file://LICENSE-MIT;md5=afb814368d9110052a22e0da67f027d3 \
"

CARGO_BUILD_FLAGS += "--locked"

# used by pkg_config crate, in turn used by libdbus_sys crate
DEPENDS += "pkgconfig-native"

DEPENDS += "dbus"
RDEPENDS:${PN} += "bash bluez5 (>=5.60) toml-cli wpa-supplicant"

do_install:append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/systemd/wifi-commissioning-gatt@.service ${D}${systemd_system_unitdir}/
    install -d ${D}${bindir}
    install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants
    ln -rs ${D}${systemd_system_unitdir}/wifi-commissioning-gatt@.service ${D}${sysconfdir}/systemd/system/multi-user.target.wants/wifi-commissioning-gatt@wlan0.service
}

FILES:${PN} += "\
    ${systemd_system_unitdir}/wifi-commissioning-gatt@.service \
"

inherit cargo_cyclonedx useradd
USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM:${PN} += "-r wifi-commissioning-gatt;"
USERADD_PARAM:${PN} += "--no-create-home -r -s /bin/false -g wifi-commissioning-gatt wifi-commissioning-gatt;"
