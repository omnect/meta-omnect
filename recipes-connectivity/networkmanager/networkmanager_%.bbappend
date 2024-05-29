FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
	file://NetworkManager.conf \
	file://cellular.generic \
"
# todo: we configure PACKAGECONFIG of networkmanager in distro conf as well: move it heres
PACKAGECONFIG:append = " modemmanager"
PACKAGECONFIG:remove = " dnsmasq"

do_install:append() {
    install -D -m 0600 ${WORKDIR}/NetworkManager.conf ${D}${sysconfdir}/NetworkManager/
    install -D -m 0600 ${WORKDIR}/cellular.generic    ${D}${sysconfdir}/NetworkManager/system-connections/cellular.generic
}

ALTERNATIVE_PRIORITY[resolv-conf] = "10"
