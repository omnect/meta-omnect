FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Override cargo-bitbake's generated S = "${WORKDIR}/git", which oe-core's
# do_qa_unpack now rejects (git unpacks to ${UNPACKDIR}/${BP}).
S = "${UNPACKDIR}/${BP}"

# Overwrite LICENSE from cargo-bitbake
LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://LICENSE-APACHE;md5=5382c4e117e2483c68e932fd10c4fd48 \
    file://LICENSE-MIT;md5=afb814368d9110052a22e0da67f027d3 \
"

CARGO_BUILD_FLAGS += "--locked --features systemd"
# BLE is compiled in when the platform can use bluetooth (device_caps-derived).
CARGO_BUILD_FLAGS += "${@bb.utils.contains('DISTRO_FEATURES', 'bluetooth', ' --features ble', '', d)}"

# Build dependencies. inherit pkgconfig exports PKG_CONFIG_LIBDIR/SYSROOT so the
# libdbus-sys crate's pkg-config probe finds the target dbus-1.pc (cargo_common
# already sets PKG_CONFIG_ALLOW_CROSS=1).
DEPENDS += "dbus"

# Runtime dependencies
RDEPENDS:${PN} += "bash wpa-supplicant"
RDEPENDS:${PN} += "${@bb.utils.contains('DISTRO_FEATURES', 'bluetooth', 'bluez5 (>=5.60)', '', d)}"

do_install:append() {
    # Install systemd template units
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/systemd/wifi-commissioning-service@.service ${D}${systemd_system_unitdir}/
    install -m 0644 ${S}/systemd/wifi-commissioning-service@.socket ${D}${systemd_system_unitdir}/

    # Source the /run env file that omnect-wifi-commissioning-start.sh writes (WCS_BLE_ARGS)
    # and expand it inside the existing bash -c invocation. No braces so BitBake does not
    # expand it; $$ becomes a literal $ for systemd -> bash sees $WCS_BLE_ARGS.
    sed -i \
        -e '\#^EnvironmentFile=-/etc/omnect/wifi-commissioning-service.env$#a EnvironmentFile=-/run/omnect-wifi-commissioning.env' \
        -e "/^ExecStart=/s|'$| \$\$WCS_BLE_ARGS'|" \
        ${D}${systemd_system_unitdir}/wifi-commissioning-service@.service

    # Fail the build if the wcs source unit format drifted and the seds above
    # no-op'd, rather than silently shipping with BLE unreachable.
    unit="${D}${systemd_system_unitdir}/wifi-commissioning-service@.service"
    grep -q '^EnvironmentFile=-/run/omnect-wifi-commissioning.env$' "$unit" || \
        bbfatal "wcs unit: /run EnvironmentFile not injected (source unit format changed?)"
    grep -q 'WCS_BLE_ARGS' "$unit" || \
        bbfatal "wcs unit: WCS_BLE_ARGS not injected into ExecStart (source unit format changed?)"

    # Without the 'bluetooth' feature there is no bluez/bluetooth.service: drop the
    # ordering. (BLE is off by default in the binary, so no runtime flag is needed here.)
    if [ "${@bb.utils.contains('DISTRO_FEATURES', 'bluetooth', 'yes', 'no', d)}" = "no" ]; then
        sed -i '/^Requires=bluetooth.service$/d;/^After=bluetooth.service$/d' \
            ${D}${systemd_system_unitdir}/wifi-commissioning-service@.service
    fi

    # No static enablement: the service is pulled by wpa_supplicant@%i.service's
    # Wants= and its own Requires=...@%i.socket; startup is gated by the
    # omnect-wifi-commissioning oneshot, which reads device_caps.json.
}

FILES:${PN} += "\
    ${systemd_system_unitdir}/wifi-commissioning-service@.service \
    ${systemd_system_unitdir}/wifi-commissioning-service@.socket \
"

inherit cargo_cyclonedx pkgconfig useradd

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM:${PN} = "-r wifi_commissioning"
USERADD_PARAM:${PN} = "--no-create-home -r -s /bin/false -g wifi_commissioning wifi_commissioning;"
