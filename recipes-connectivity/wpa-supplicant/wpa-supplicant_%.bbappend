FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://wpa_supplicant.conf\
    file://wpa_supplicant@.service\
    "

do_install:append() {
    install -m 0644 ${WORKDIR}/wpa_supplicant.conf ${D}${sysconfdir}/wpa_supplicant.conf
    install -m 0644 ${WORKDIR}/wpa_supplicant@.service ${D}${systemd_system_unitdir}/wpa_supplicant@.service
    install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants
    ln -rs ${D}${systemd_system_unitdir}/wpa_supplicant@.service ${D}${sysconfdir}/systemd/system/multi-user.target.wants/wpa_supplicant@wlan0.service
}

inherit useradd

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM:${PN} = "-r wpa_supplicant;"
