SYSTEMD_AUTO_ENABLE:omnect-os:util-linux-fstrim = "enable"

do_install:append() {
    # install fstrim's systemd service and timer files
    install -d -m 0755  ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/sys-utils/fstrim.service.in ${D}${systemd_system_unitdir}/fstrim.service
    install -m 0644 ${S}/sys-utils/fstrim.timer ${D}${systemd_system_unitdir}/fstrim.timer

    # we don't need cramfs stuff so remove it from deploy dir
    rm -f ${D}${base_sbindir}/fsck.cramfs
    rm -f ${D}${base_sbindir}/mkfs.cramfs
}

FILES:${PN}:append = "\
	${systemd_system_unitdir}/fstrim.service \
	${systemd_system_unitdir}/fstrim.timer \
"