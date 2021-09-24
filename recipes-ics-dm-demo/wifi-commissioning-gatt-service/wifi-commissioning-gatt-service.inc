SRC_URI += "file://wifi-commissioning-gatt@.service"

DEPENDS += "dbus"

do_install_append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/wifi-commissioning-gatt@.service ${D}${systemd_system_unitdir}/
}

do_install_append_rpi() {
    install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants
    lnr ${D}${systemd_system_unitdir}/wifi-commissioning-gatt@.service ${D}${sysconfdir}/systemd/system/multi-user.target.wants/wifi-commissioning-gatt@wlan0.service
}

FILES_${PN} += "${systemd_system_unitdir}/wifi-commissioning-gatt@.service"
