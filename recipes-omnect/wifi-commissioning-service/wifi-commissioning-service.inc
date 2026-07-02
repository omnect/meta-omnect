FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

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
    # Install systemd template units
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/systemd/wifi-commissioning-service@.service ${D}${systemd_system_unitdir}/
    install -m 0644 ${S}/systemd/wifi-commissioning-service@.socket ${D}${systemd_system_unitdir}/

    # Runtime ExecStart override: decide --disable-ble from BT-adapter presence.
    install -d ${D}${systemd_system_unitdir}/wifi-commissioning-service@.service.d
    install -m 0644 ${WORKDIR}/10-omnect-runtime.conf \
        ${D}${systemd_system_unitdir}/wifi-commissioning-service@.service.d/10-omnect-runtime.conf

    # When bluetooth is absent from the build there is no bluez/bluetooth.service
    # and BLE can never work. Strip the (now non-existent) bluetooth.service
    # dependency and force --disable-ble, overriding the runtime adapter probe in
    # 10-omnect-runtime.conf (a kernel HCI adapter can exist without bluez).
    if [ "${@bb.utils.contains('DISTRO_FEATURES', 'bluetooth', 'yes', 'no', d)}" = "no" ]; then
        sed -i '/^Requires=bluetooth.service$/d' \
            ${D}${systemd_system_unitdir}/wifi-commissioning-service@.service
        sed -i '/^After=bluetooth.service$/d' \
            ${D}${systemd_system_unitdir}/wifi-commissioning-service@.service
        printf '%s\n' 'Environment=WIFI_COMMISSIONING_EXTRA_ARGS=--disable-ble' >> \
            ${D}${systemd_system_unitdir}/wifi-commissioning-service@.service.d/10-omnect-runtime.conf
    fi

    # No static enablement: the service is pulled by wpa_supplicant's Wants=
    # and its own Requires=...@%i.socket, gated by the wlan udev rule.
}

FILES:${PN} += "\
    ${systemd_system_unitdir}/wifi-commissioning-service@.service \
    ${systemd_system_unitdir}/wifi-commissioning-service@.socket \
    ${systemd_system_unitdir}/wifi-commissioning-service@.service.d/10-omnect-runtime.conf \
"

inherit cargo_cyclonedx useradd

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM:${PN} = "-r wifi_commissioning"
USERADD_PARAM:${PN} = "--no-create-home -r -s /bin/false -g wifi_commissioning wifi_commissioning;"
