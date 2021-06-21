FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://80-wlan.network \
    file://first-boot.service \
    file://ics_dm_first_boot.sh \
"

RDEPENDS_${PN} += "bash"

do_install_append() {
    install -d ${D}${systemd_system_unitdir}

    # enable dhcp for wlan devices
    install -m 0644 ${WORKDIR}/80-wlan.network ${D}${systemd_unitdir}/network/

    # first boot handling
    install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants
    install -m 0644 ${WORKDIR}/first-boot.service ${D}${systemd_system_unitdir}/
    lnr ${D}${systemd_system_unitdir}/first-boot.service ${D}${sysconfdir}/systemd/system/multi-user.target.wants/first-boot.service
    install -m 0755 -D ${WORKDIR}/ics_dm_first_boot.sh ${D}${bindir}/

    #persistent journal
    if ${@bb.utils.contains('DISTRO_FEATURES', 'persistent-journal', 'true', 'false', d)}; then
        sed -i 's/^#Storage=auto/Storage=persistent/' ${D}${sysconfdir}/systemd/journald.conf

        # (Re)create journal folder permissions in data partions, e.g. after a
        # factory reset via tmpfiles.d.
        # (https://www.freedesktop.org/software/systemd/man/tmpfiles.d.html).
        #
        # We need that for scenarios where you update from an image without
        # persistent journal to an image where persistent journal is enabled.
        # Note: /mnt/data/journal is created in initramfs
        echo "z /mnt/data/journal 2750 root systemd-journal - -"                    >> ${D}${libdir}/tmpfiles.d/persistent_journal.conf
        echo "z /mnt/data/journal/%m 2755 root systemd-journal - -"                 >> ${D}${libdir}/tmpfiles.d/persistent_journal.conf
        echo "z /mnt/data/journal/%m/system.journal 0640 root systemd-journal - -"  >> ${D}${libdir}/tmpfiles.d/persistent_journal.conf

        # Enable persistent machine-id creation only if journal is persistent
        # Note: We can not simply create an etc-machine\x2did.mount unit.
        #       Systemd creates a tmpfs mtab entry for /etc/machine-id which
        #       prevents that we can mount /etc/machine-id with
        #       "Where=" in etc-machine\x2did.mount.
        #       Thus we do it as "ExecStartPre=" step in
        #       systemd-machine-id-commit.service.
        sed -i -E '/^ConditionPathIsMountPoint=(.*)/d' ${D}${systemd_system_unitdir}/systemd-machine-id-commit.service
        sed -i -E 's?^ConditionPathIsReadWrite=(.*)?ConditionPathExists=!/mnt/etc/upper/machine-id?' ${D}${systemd_system_unitdir}/systemd-machine-id-commit.service
        sed -i -E 's?^ExecStart=(.*)?ExecStartPre=touch /mnt/etc/upper/machine-id\nExecStartPre=mount -o bind /mnt/etc/upper/machine-id /etc/machine-id\nExecStart=/bin/systemd-machine-id-setup?' ${D}${systemd_system_unitdir}/systemd-machine-id-commit.service
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

FILES_${PN} += "\
    /usr/bin/ics_dm_first_boot.sh \
    ${systemd_unitdir}/network/80-wlan.network \
"
