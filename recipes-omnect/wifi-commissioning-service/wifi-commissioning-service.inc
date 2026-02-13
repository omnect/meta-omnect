# Overwrite LICENSE from cargo-bitbake
LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://LICENSE-APACHE;md5=5382c4e117e2483c68e932fd10c4fd48 \
    file://LICENSE-MIT;md5=afb814368d9110052a22e0da67f027d3 \
"

CARGO_BUILD_FLAGS += "--locked --features systemd"

# Build dependencies
DEPENDS += "pkgconfig-native dbus"

# Runtime dependencies
RDEPENDS:${PN} += "bash wpa-supplicant"
RDEPENDS:${PN} += "${@bb.utils.contains('DISTRO_FEATURES', 'bluetooth', 'bluez5 (>=5.60)', '', d)}"

do_install:append() {
    # Install systemd units
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/systemd/wifi-commissioning-service.service ${D}${systemd_system_unitdir}/
    install -m 0644 ${S}/systemd/wifi-commissioning-service.socket ${D}${systemd_system_unitdir}/

    # Set socket group to omnect_device_service_client (GID 10000) so containers
    # can access the socket via their primary group — same pattern as omnect-device-service
    sed -i 's/^SocketGroup=wpa_supplicant$/SocketGroup=omnect_device_service_client/' \
        ${D}${systemd_system_unitdir}/wifi-commissioning-service.socket

    # Add wpa_supplicant as supplementary group so the service can access
    # wpa_supplicant's control socket at /var/run/wpa_supplicant/<iface>
    sed -i '/^Group=wifi_commissioning$/a SupplementaryGroups=wpa_supplicant' \
        ${D}${systemd_system_unitdir}/wifi-commissioning-service.service

    # Disable BLE transport when bluetooth is not available
    if [ "${@bb.utils.contains('DISTRO_FEATURES', 'bluetooth', 'yes', 'no', d)}" = "no" ]; then
        sed -i "/^ExecStart/s|'$| --no-enable-ble'|" \
            ${D}${systemd_system_unitdir}/wifi-commissioning-service.service
    fi

    # Enable service and socket
    install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants
    ln -rs ${D}${systemd_system_unitdir}/wifi-commissioning-service.service \
        ${D}${sysconfdir}/systemd/system/multi-user.target.wants/wifi-commissioning-service.service

    install -d ${D}${sysconfdir}/systemd/system/sockets.target.wants
    ln -rs ${D}${systemd_system_unitdir}/wifi-commissioning-service.socket \
        ${D}${sysconfdir}/systemd/system/sockets.target.wants/wifi-commissioning-service.socket
}

FILES:${PN} += "\
    ${systemd_system_unitdir}/wifi-commissioning-service.service \
    ${systemd_system_unitdir}/wifi-commissioning-service.socket \
"

inherit cargo_cyclonedx wifi-commissioning-service
