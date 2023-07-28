FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
	file://0001-wwan-fix-provision-of-IPv6-addresses.patch \
	file://NetworkManager.conf \
"

PACKAGECONFIG:append = " modemmanager"
PACKAGECONFIG:remove = " dnsmasq"

do_install:append() {
    install -m 0600 ${WORKDIR}/NetworkManager.conf ${D}${sysconfdir}/NetworkManager/
}

ALTERNATIVE_PRIORITY[resolv-conf] = "10"
