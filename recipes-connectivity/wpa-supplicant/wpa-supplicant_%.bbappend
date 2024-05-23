FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://wpa_supplicant-wlan0.conf"

do_install:append() {
    if ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', 'true', 'false', d)}; then
        # don't enable
        install -d ${D}${sysconfdir}/wpa_supplicant
        install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants
        if [ -n "${OMNECT_WLAN0}" ]; then
            install -m 0644 ${WORKDIR}/wpa_supplicant-wlan0.conf ${D}${sysconfdir}/wpa_supplicant/wpa_supplicant-${OMNECT_WLAN0}.conf
            ln -rs ${D}${systemd_system_unitdir}/wpa_supplicant@.service ${D}${sysconfdir}/systemd/system/multi-user.target.wants/wpa_supplicant@${OMNECT_WLAN0}.service
        else
            install -m 0644 ${WORKDIR}/wpa_supplicant-wlan0.conf ${D}${sysconfdir}/wpa_supplicant/wpa_supplicant-wlan0.conf
            # don't enable wpa_supplicant if OMNECT_WLAN0 is not set
        fi
    fi
}

inherit useradd

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM:${PN} = "-r wpa_supplicant;"
