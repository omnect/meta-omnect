FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://wpa_supplicant.conf\
    file://wpa_supplicant@.service\
    file://80-wlan-wpa.rules\
    "

do_install:append() {
    install -m 0644 ${WORKDIR}/wpa_supplicant.conf ${D}${sysconfdir}/wpa_supplicant.conf
    install -m 0644 ${WORKDIR}/wpa_supplicant@.service ${D}${systemd_system_unitdir}/wpa_supplicant@.service
    install -d ${D}${nonarch_base_libdir}/udev/rules.d
    install -m 0644 ${WORKDIR}/80-wlan-wpa.rules ${D}${nonarch_base_libdir}/udev/rules.d/80-wlan-wpa.rules
}

inherit useradd

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM:${PN} = "-r wpa_supplicant;"

FILES:${PN} += "${nonarch_base_libdir}/udev/rules.d/80-wlan-wpa.rules"
