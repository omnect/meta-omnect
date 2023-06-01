FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
	file://NetworkManager.conf \
	file://cellular \
"

PACKAGECONFIG:append = " modemmanager"
PACKAGECONFIG:remove = " dnsmasq"

do_install:append() {
    install -m 0600 ${WORKDIR}/NetworkManager.conf ${D}${sysconfdir}/NetworkManager/
    install -m 0600 ${WORKDIR}/cellular ${D}${sysconfdir}/NetworkManager/system-connections/cellular
}

ALTERNATIVE_PRIORITY[resolv-conf] = "10"