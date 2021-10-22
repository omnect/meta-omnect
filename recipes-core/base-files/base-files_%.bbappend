FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

do_install_append() {
    # install mountpoints
    install -d -D ${D}/mnt/data \
    install -d -D ${D}/mnt/etc \
    install -d -D ${D}/var/lib \
    install -d -D ${D}${exec_prefix}/local

    # explicitly remove fstab to prevent remounting / by systemd
    rm ${D}${sysconfdir}/fstab

    # adapt system wide environment
    install -d -D ${D}/etc/profile.d
    install -m 0644 ${WORKDIR}/ics-dm_profile.sh ${D}/etc/profile.d
}

SRC_URI += "\
    file://ics-dm_profile.sh \
"

FILES_${PN} += "\
    /mnt/data \
    /mnt/etc \
    /var/lib \
    ${exec_prefix}/local \
    /etc/profile.d \
    /etc/profile.d/ics-dm_profile.sh \
"
