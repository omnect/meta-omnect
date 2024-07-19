do_install:append() {
    rm ${D}/${bindir}/pkexec
    rm ${D}/${bindir}/pkttyagent
}
