FILESEXTRAPATHS:prepend := "${LAYERDIR_omnect}/files/device_caps:"
SRC_URI += "file://${MACHINE}.json"
do_install:append() {
    sed -i 's/^export PS1=\(.*\)$/[ -z \"\$PS1\" ] \&\& export PS1=\1/' ${D}/etc/skel/.bashrc
    install -m 0644 -D ${WORKDIR}/${MACHINE}.json ${D}${sysconfdir}/omnect/device_caps.json
}
FILES_${PN} += "${sysconfdir}/omnect/device_caps.json"
