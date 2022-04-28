FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://80-wlan.network \
    file://ics-dm-first-boot.service \
    file://ics_dm_first_boot.sh \
    file://0001-util-return-the-correct-correct-wd-from-inotify-help.patch \
"

RDEPENDS:${PN} += "bash"

do_install:append() {
    install -d ${D}${systemd_system_unitdir}

    # enable dhcp for wlan devices
    install -m 0644 ${WORKDIR}/80-wlan.network ${D}${systemd_unitdir}/network/
    sed -i 's/^Name=wlan0/Name=${ICS_DM_WLAN0}/' ${D}${systemd_unitdir}/network/80-wlan.network
    sed -i -e 's/^ExecStart=\(.*\)/ExecStart=\1 --any --interface=${ICS_DM_ETH0} --interface=${ICS_DM_WLAN0}/' ${D}${systemd_system_unitdir}/systemd-networkd-wait-online.service

    # first boot handling
    install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants
    install -m 0644 ${WORKDIR}/ics-dm-first-boot.service ${D}${systemd_system_unitdir}/
    lnr ${D}${systemd_system_unitdir}/ics-dm-first-boot.service ${D}${sysconfdir}/systemd/system/multi-user.target.wants/ics-dm-first-boot.service
    install -m 0755 -D ${WORKDIR}/ics_dm_first_boot.sh ${D}${bindir}/

    # persistent /var/log
    if ${@bb.utils.contains('DISTRO_FEATURES', 'persistent-var-log', 'true', 'false', d)}; then
        sed -i 's/^#Storage=auto/Storage=persistent/' ${D}${sysconfdir}/systemd/journald.conf

        # (Re)create journal folder permissions in data partions, e.g. after a
        # factory reset via tmpfiles.d.
        # (https://www.freedesktop.org/software/systemd/man/tmpfiles.d.html).
        #
        # We need that for scenarios where you update from an image without
        # persistent /var/log to an image where persistent /var/log is enabled.
        echo "z /var/log/journal 2750 root systemd-journal - -"                    >> ${D}${libdir}/tmpfiles.d/persistent_journal.conf
        echo "z /var/log/journal/%m 2755 root systemd-journal - -"                 >> ${D}${libdir}/tmpfiles.d/persistent_journal.conf
        echo "z /var/log/journal/%m/system.journal 0640 root systemd-journal - -"  >> ${D}${libdir}/tmpfiles.d/persistent_journal.conf
    fi

    # configure journald
    [ ! -z ${JOURNALD_SystemMaxUse} ]       && sed -i 's/^#SystemMaxUse=/SystemMaxUse=${JOURNALD_SystemMaxUse} /' ${D}${sysconfdir}/systemd/journald.conf
    [ ! -z ${JOURNALD_SystemKeepFree} ]     && sed -i 's/^#SystemKeepFree=/SystemKeepFree=${JOURNALD_SystemKeepFree} /' ${D}${sysconfdir}/systemd/journald.conf
    [ ! -z ${JOURNALD_SystemMaxFileSize} ]  && sed -i 's/^#SystemMaxFileSize=/SystemMaxFileSize=${JOURNALD_SystemMaxFileSize} /' ${D}${sysconfdir}/systemd/journald.conf
    [ ! -z ${JOURNALD_SystemMaxFiles} ]     && sed -i 's/^#SystemMaxFiles=/SystemMaxFiles=${JOURNALD_SystemMaxFiles} /' ${D}${sysconfdir}/systemd/journald.conf
    [ ! -z ${JOURNALD_RuntimeMaxUse} ]      && sed -i 's/^#RuntimeMaxUse=/RuntimeMaxUse=${JOURNALD_RuntimeMaxUse} /' ${D}${sysconfdir}/systemd/journald.conf
    [ ! -z ${JOURNALD_RuntimeKeepFree} ]    && sed -i 's/^#RuntimeKeepFree=/RuntimeKeepFree=${JOURNALD_RuntimeKeepFree} /' ${D}${sysconfdir}/systemd/journald.conf
    [ ! -z ${JOURNALD_RuntimeMaxFileSize} ] && sed -i 's/^#RuntimeMaxFileSize=/RuntimeMaxFileSize=${JOURNALD_RuntimeMaxFileSize} /' ${D}${sysconfdir}/systemd/journald.conf
    [ ! -z ${JOURNALD_RuntimeMaxFiles} ]    && sed -i 's/^#RuntimeMaxFiles=/RuntimeMaxFiles=${JOURNALD_RuntimeMaxFiles} /' ${D}${sysconfdir}/systemd/journald.conf
    [ ! -z ${JOURNALD_ForwardToSyslog} ]    && sed -i -E 's/^#ForwardToSyslog=(.*)/ForwardToSyslog=${JOURNALD_ForwardToSyslog} /' ${D}${sysconfdir}/systemd/journald.conf

    # sync time on sysinit
    install -d ${D}${sysconfdir}/systemd/system/sysinit.target.wants
    lnr ${D}${systemd_system_unitdir}/systemd-time-wait-sync.service ${D}${sysconfdir}/systemd/system/sysinit.target.wants/systemd-time-wait-sync.service
}

# for rpi3 and rpi4, use hardware watchdog (see MACHINEOVERRIDES)
do_install:append:rpi() {
    local cfg_file="${D}${sysconfdir}/systemd/system.conf"
    [ -n ${SYSTEMD_RuntimeWatchdogSec}  ] && \
        sed -i 's|^#RuntimeWatchdogSec=.*$|RuntimeWatchdogSec=${SYSTEMD_RuntimeWatchdogSec}|' ${cfg_file}
    [ -n ${SYSTEMD_RebootWatchdogSec}   ] && \
        sed -i 's|^#RebootWatchdogSec=.*$|RebootWatchdogSec=${SYSTEMD_RebootWatchdogSec}|' ${cfg_file}
    [ -n ${SYSTEMD_ShutdownWatchdogSec} ] && \
        sed -i 's|^#ShutdownWatchdogSec=.*$|ShutdownWatchdogSec=${SYSTEMD_ShutdownWatchdogSec}|' ${cfg_file}
}

FILES:${PN} += "\
    /usr/bin/ics_dm_first_boot.sh \
    ${systemd_unitdir}/network/80-wlan.network \
"
