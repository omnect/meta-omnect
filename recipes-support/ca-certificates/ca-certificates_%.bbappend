do_install_append_class-target () {
    sed -i -e 's,/etc/,${sysconfdir}/,' \
           -e 's,/usr/share/,${datadir}/,' \
           -e 's,/usr/local,${prefix}/local,' \
        ${D}${sbindir}/update-ca-certificates \
        ${D}${mandir}/man8/update-ca-certificates.8

    install -d ${D}${libdir}/ssl-1.1
    lnr ${D}${sysconfdir}/ssl/certs ${D}${libdir}/ssl-1.1/certs
}

FILES_${PN} += "${libdir}/ssl-1.1/certs"

# update-ca-certificates is not working when we include the following patch
# which poky applies
SRC_URI_remove = "file://update-ca-certificates-support-Toybox.patch"
