# Overwrite LICENSE from cargo-bitbake
LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://LICENSE-APACHE;md5=5382c4e117e2483c68e932fd10c4fd48 \
    file://LICENSE-MIT;md5=afb814368d9110052a22e0da67f027d3 \
"

CARGO_BUILD_FLAGS += "--locked --features systemd"

# wifi-commissioning without wifi makes no sense
python () {
    if bb.utils.contains('DISTRO_FEATURES', 'wifi-commissioning', True, False, d) and \
       not bb.utils.contains('DISTRO_FEATURES', 'wifi', True, False, d):
        bb.fatal("DISTRO_FEATURES contains 'wifi-commissioning' but not 'wifi'")
}

# Build dependencies
DEPENDS += "pkgconfig-native dbus"

# Runtime dependencies
RDEPENDS:${PN} += "bash wpa-supplicant"
RDEPENDS:${PN} += "${@bb.utils.contains('DISTRO_FEATURES', 'bluetooth', 'bluez5 (>=5.60)', '', d)}"

do_install:append() {
    # Install systemd template units
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/systemd/wifi-commissioning-service@.service ${D}${systemd_system_unitdir}/
    install -m 0644 ${S}/systemd/wifi-commissioning-service@.socket ${D}${systemd_system_unitdir}/

    # When bluetooth is absent: remove bluetooth deps and disable BLE transport
    if [ "${@bb.utils.contains('DISTRO_FEATURES', 'bluetooth', 'yes', 'no', d)}" = "no" ]; then
        sed -i '/^Requires=bluetooth.service$/d' \
            ${D}${systemd_system_unitdir}/wifi-commissioning-service@.service
        sed -i '/^After=bluetooth.service$/d' \
            ${D}${systemd_system_unitdir}/wifi-commissioning-service@.service
        sed -i "/^ExecStart/s|'$| --disable-ble'|" \
            ${D}${systemd_system_unitdir}/wifi-commissioning-service@.service
    fi

    # Enable wlan0 instance for service and socket
    install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants
    ln -rs ${D}${systemd_system_unitdir}/wifi-commissioning-service@.service \
        ${D}${sysconfdir}/systemd/system/multi-user.target.wants/wifi-commissioning-service@wlan0.service

    install -d ${D}${sysconfdir}/systemd/system/sockets.target.wants
    ln -rs ${D}${systemd_system_unitdir}/wifi-commissioning-service@.socket \
        ${D}${sysconfdir}/systemd/system/sockets.target.wants/wifi-commissioning-service@wlan0.socket
}

FILES:${PN} += "\
    ${systemd_system_unitdir}/wifi-commissioning-service@.service \
    ${systemd_system_unitdir}/wifi-commissioning-service@.socket \
"

inherit cargo_cyclonedx useradd

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM:${PN} = "-r wifi_commissioning"
USERADD_PARAM:${PN} = "--no-create-home -r -s /bin/false -g wifi_commissioning wifi_commissioning;"
