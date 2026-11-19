# Same file as the build configuration reads; prepended last, so it is searched first.
FILESEXTRAPATHS:prepend := "${@os.path.dirname(omnect.device_caps.find_json_path(d))}:"
SRC_URI += "file://${MACHINE}.json"
do_install:append() {
    sed -i 's/^export PS1=\(.*\)$/[ -z \"\$PS1\" ] \&\& export PS1=\1/' ${D}/etc/skel/.bashrc
    install -m 0644 -D ${UNPACKDIR}/${MACHINE}.json ${D}${sysconfdir}/omnect/device_caps.json
}
FILES:${PN} += "${sysconfdir}/omnect/device_caps.json"
