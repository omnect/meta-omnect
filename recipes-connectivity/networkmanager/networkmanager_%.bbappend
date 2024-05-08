FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
	file://NetworkManager.conf \
"
# todo: we configure PACKAGECONFIG of networkmanager in distro conf as well: move it heres
PACKAGECONFIG:append = " modemmanager"
PACKAGECONFIG:remove = " dnsmasq"

do_install:append() {
    install -m 0600 ${WORKDIR}/NetworkManager.conf ${D}${sysconfdir}/NetworkManager/
}

ALTERNATIVE_PRIORITY[resolv-conf] = "10"
