FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://80-wlan.network \
    file://aziot-identityd-startup-timeout-lte.conf \
"

RDEPENDS:${PN} += "bash"

# enable bash-completion
bashcompletiondir = "${datadir}/bash-completion/completions"

do_install:append() {
    install -d ${D}${systemd_system_unitdir}

    # reboot on systemd-networkd-wait online failure
    sed -i \
        -e 's/^\[Unit\]/\[Unit\]\nOnFailure=systemd-reboot.service/' \
        -e 's#^ExecStart=\(.*\)#EnvironmentFile=-/etc/omnect/systemd-networkd-wait-online.env\nExecStart=\1#' \
        ${D}${systemd_system_unitdir}/systemd-networkd-wait-online.service

    if ${@bb.utils.contains('MACHINE_FEATURES', 'wifi', 'true', 'false', d)}; then
        # enable dhcp for wlan devices
        install -m 0644 ${WORKDIR}/80-wlan.network ${D}${systemd_unitdir}/network
        sed -i 's/^Name=wlan0/Name=${OMNECT_WLAN0}/' ${D}${systemd_unitdir}/network/80-wlan.network
    fi

    # persistent /var/log
    if ${@bb.utils.contains('DISTRO_FEATURES', 'persistent-var-log', 'true', 'false', d)}; then
        sed -i 's/^#Storage=auto/Storage=persistent/' ${D}${sysconfdir}/systemd/journald.conf

        # fix journal corruption on reboot resp. "umount of /var/log failed"
        sed -i 's/^\[Unit\]/\[Unit\]\nPartOf=var-log.mount/' ${D}${systemd_system_unitdir}/systemd-journal-flush.service

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
    [ -n "${JOURNALD_SystemMaxUse}" ]       && sed -i 's/^#SystemMaxUse=/SystemMaxUse=${JOURNALD_SystemMaxUse} /' ${D}${sysconfdir}/systemd/journald.conf
    [ -n "${JOURNALD_SystemKeepFree}" ]     && sed -i 's/^#SystemKeepFree=/SystemKeepFree=${JOURNALD_SystemKeepFree} /' ${D}${sysconfdir}/systemd/journald.conf
    [ -n "${JOURNALD_SystemMaxFileSize}" ]  && sed -i 's/^#SystemMaxFileSize=/SystemMaxFileSize=${JOURNALD_SystemMaxFileSize} /' ${D}${sysconfdir}/systemd/journald.conf
    [ -n "${JOURNALD_SystemMaxFiles}" ]     && sed -i 's/^#SystemMaxFiles=/SystemMaxFiles=${JOURNALD_SystemMaxFiles} /' ${D}${sysconfdir}/systemd/journald.conf
    [ -n "${JOURNALD_RuntimeMaxUse}" ]      && sed -i 's/^#RuntimeMaxUse=/RuntimeMaxUse=${JOURNALD_RuntimeMaxUse} /' ${D}${sysconfdir}/systemd/journald.conf
    [ -n "${JOURNALD_RuntimeKeepFree}" ]    && sed -i 's/^#RuntimeKeepFree=/RuntimeKeepFree=${JOURNALD_RuntimeKeepFree} /' ${D}${sysconfdir}/systemd/journald.conf
    [ -n "${JOURNALD_RuntimeMaxFileSize}" ] && sed -i 's/^#RuntimeMaxFileSize=/RuntimeMaxFileSize=${JOURNALD_RuntimeMaxFileSize} /' ${D}${sysconfdir}/systemd/journald.conf
    [ -n "${JOURNALD_RuntimeMaxFiles}" ]    && sed -i 's/^#RuntimeMaxFiles=/RuntimeMaxFiles=${JOURNALD_RuntimeMaxFiles} /' ${D}${sysconfdir}/systemd/journald.conf
    [ -n "${JOURNALD_ForwardToSyslog}" ]    && sed -i -E 's/^#ForwardToSyslog=(.*)/ForwardToSyslog=${JOURNALD_ForwardToSyslog} /' ${D}${sysconfdir}/systemd/journald.conf

    # sync time on sysinit
    install -d ${D}${sysconfdir}/systemd/system/sysinit.target.wants
    ln -rs ${D}${systemd_system_unitdir}/systemd-time-wait-sync.service ${D}${sysconfdir}/systemd/system/sysinit.target.wants/systemd-time-wait-sync.service

    # configure logind
    # https://www.freedesktop.org/software/systemd/man/logind.conf.html
    if ${@bb.utils.contains('OMNECT_RELEASE_IMAGE', '1', 'true', 'false', d)}; then
        sed -i \
            -e 's/^#NAutoVTs=\(.*\)$/NAutoVTs=0 /' \
            -e 's/^#ReserveVT=\(.*\)$/ReserveVT=0 /' \
            ${D}${sysconfdir}/systemd/logind.conf
    fi
}

enable_hardware_watchdog() {
    local cfg_file="${D}${sysconfdir}/systemd/system.conf"

    [ -n "${SYSTEMD_RuntimeWatchdogSec}"  ] && \
        sed -i 's|^#\(RuntimeWatchdogSec\)=.*$|\1=${SYSTEMD_RuntimeWatchdogSec}|' ${cfg_file}
    [ -n "${SYSTEMD_RebootWatchdogSec}"   ] && \
        sed -i 's|^#\(RebootWatchdogSec\)=.*$|\1=${SYSTEMD_RebootWatchdogSec}|' ${cfg_file}
}

# enable hardware watchdog for rpi3, rpi4, phygate tauri-l and phyboard polis (see MACHINEOVERRIDES)
do_install:append:rpi() {
    enable_hardware_watchdog
}
do_install:append:phygate-tauri-l-imx8mm-2() {
    enable_hardware_watchdog
}
do_install:append:phyboard-polis-imx8mm-4() {
    enable_hardware_watchdog
}


def online_ifc_list_to_parameter_list(d, ifclistvar):
    param_list = ''
    ifclist = d.getVar(ifclistvar)
    if ifclist == None:
        bb.warn('No online interfaces defined in variable {}!'.format(ifclistvar))
        return param_list
    interfaces = ifclist.split(':')
    if len(interfaces) > 1:
        param_list = '--any '
    for i in interfaces:
        param_list += '--interface={} '.format(i)
    return param_list

ONLINE_INTERFACE_ARGS = "${@online_ifc_list_to_parameter_list(d, 'OMNECT_ONLINE_INTERFACES')}"

do_install:append() {
    sed -i -e 's#^ExecStart=\(.*\)#ExecStart=/bin/bash -c \x27\1 \${OMNECT_WAIT_ONLINE_INTERFACES:-${ONLINE_INTERFACE_ARGS}} --timeout=\${OMNECT_WAIT_ONLINE_TIMEOUT_IN_SECS:-300}\x27#' \
        ${D}${systemd_system_unitdir}/systemd-networkd-wait-online.service
    if ${@bb.utils.contains('DISTRO_FEATURES', '3g', 'true', 'false', d)}; then
	install -d ${D}${sysconfdir}/systemd/system/aziot-identityd.service.d
	install -m 0644 ${WORKDIR}/aziot-identityd-startup-timeout-lte.conf ${D}${sysconfdir}/systemd/system/aziot-identityd.service.d/startup-timeout.conf
    fi
}

# adapt welotronic eg500 systemd-networkd-wait-online.service state
do_install:append:eg500() {
    sed -i -e 's#^ExecStart=\(.*\)#ExecStart=/bin/bash -c \x27\1 ${OMNECT_WAIT_ONLINE_INTERFACES:-${ONLINE_INTERFACE_ARGS}} --timeout=\${OMNECT_WAIT_ONLINE_TIMEOUT_IN_SECS:-300}\x27#' \
        ${D}${systemd_system_unitdir}/systemd-networkd-wait-online.service
}

FILES:${PN} += "\
    ${systemd_unitdir}/network/80-wlan.network \
    ${@bb.utils.contains('DISTRO_FEATURES', '3g', '${sysconfdir}/systemd/system/aziot-identityd.service.d/startup-timeout.conf', '', d)} \
"
