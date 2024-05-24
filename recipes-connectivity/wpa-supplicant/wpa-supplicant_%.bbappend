FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://wpa_supplicant.conf"

do_install:append() {
    install -m 0644 ${WORKDIR}/wpa_supplicant.conf ${D}${sysconfdir}/wpa_supplicant.conf
}

inherit useradd

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM:${PN} = "-r wpa_supplicant;"
SYSTEMD_AUTO_ENABLE = "enable"
