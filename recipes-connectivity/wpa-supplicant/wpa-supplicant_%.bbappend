FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://wpa_supplicant-wlan0.conf"

do_install:append() {
    if ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', 'true', 'false', d)}; then
        install -d ${D}${sysconfdir}/wpa_supplicant
        install -m 0644 ${WORKDIR}/wpa_supplicant-wlan0.conf ${D}${sysconfdir}/wpa_supplicant/wpa_supplicant-wlan0.conf
        install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants
        lnr ${D}${systemd_system_unitdir}/wpa_supplicant@.service ${D}${sysconfdir}/systemd/system/multi-user.target.wants/wpa_supplicant@wlan0.service
    fi
}

inherit useradd

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM:${PN} = "-r wpa_supplicant;"
