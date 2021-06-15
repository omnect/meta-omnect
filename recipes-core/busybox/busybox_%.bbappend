do_install_append() {
    if ${@bb.utils.contains('SRC_URI', 'file://syslog.cfg', 'false','true', d)} && \
       ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true','false', d)} ; then
        rm ${D}${systemd_unitdir}/system/busybox-klogd.service
        cd ${D} && rmdir -p lib/systemd/system
    fi
}
