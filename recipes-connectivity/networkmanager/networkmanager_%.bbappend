FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
	file://NetworkManager.conf \
	file://cellular.generic \
"
# networkmanager: we removed qemu-usermode from MACHINE_FEATURES, this results
# in failure of networkmanager configuration step for gobject-introspection,
# unless we build without vala support
PACKAGECONFIG:append = " modemmanager"
PACKAGECONFIG:remove = "dnsmasq vala"

do_install:append() {
    install -D -m 0600 ${WORKDIR}/NetworkManager.conf ${D}${sysconfdir}/NetworkManager/
    install -D -m 0600 ${WORKDIR}/cellular.generic    ${D}${sysconfdir}/NetworkManager/system-connections/cellular.generic
}

ALTERNATIVE_PRIORITY[resolv-conf] = "10"
