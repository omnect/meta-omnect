FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

do_install:append() {
    # FCC unlock for Sierra Wireless EM7455
    install -d ${D}${sysconfdir}/ModemManager/fcc-unlock.d/

    # Sierra Wireless AirPrime EM7455
    ln -sf ${datadir}/ModemManager/fcc-unlock.available.d/1199\:9079 ${D}${sysconfdir}/ModemManager/fcc-unlock.d/
}
