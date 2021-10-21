# allow user ics-dm to run sudo (with password)
do_install_append () {
    install -d ${D}${sysconfdir}/sudoers.d/
    echo "ics-dm ALL=(ALL:ALL) ALL" >${D}${sysconfdir}/sudoers.d/001_ics-dm
}
