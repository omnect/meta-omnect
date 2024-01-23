
# overwrite LICENSE and LIC_FILES_CHKSUM from cargo-bitbake generated recipe
LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://LICENSE-APACHE;md5=650e893673eb59696f3d4ee64f6d2357 \
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
    ln -rs ${D}${systemd_system_unitdir}/wifi-commissioning-gatt@.service ${D}${sysconfdir}/systemd/system/multi-user.target.wants/wifi-commissioning-gatt@${OMNECT_WLAN0}.service
}

# for post process handling we deploy PV
inherit deploy
do_deploy() {
    echo "${PV}" > "${DEPLOYDIR}/wifi-commissioning-gatt-service.version"
}
addtask do_deploy after do_compile before do_build

FILES:${PN} += "\
    ${systemd_system_unitdir}/wifi-commissioning-gatt@.service \
"

inherit useradd
USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM:${PN} += "-r wifi-commissioning-gatt;"
USERADD_PARAM:${PN} += "--no-create-home -r -s /bin/false -g wifi-commissioning-gatt wifi-commissioning-gatt;"
