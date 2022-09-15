do_install:append () {
    # if wifi-commissioning restarts with errors like
    # Error: Error { kind: Internal(DBus("org.freedesktop.DBus.Error.UnknownMethod")), message: "Method \"RegisterAdvertisement\" with signature \"oa{sv}\" on interface \"org.bluez.LEAdvertisingManager1\" doesn't exist\n" }
    # only a restart of bluetooth helps
    if ${@bb.utils.contains('DISTRO_FEATURES', 'wifi-commissioning', 'true', 'false', d)}; then
        sed -i -e 's/^ConditionPathIsDirectory=\(.*\)$/ConditionPathIsDirectory=\1\nPartOf=wifi-commissioning-gatt@wlan0.service/' \
        ${D}${systemd_system_unitdir}/bluetooth.service
    fi
}
