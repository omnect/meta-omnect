# openssl-misc is dropped from PACKAGES, which leaves its perl scripts in the
# main package - remove the files as well.
do_install:append:class-target() {
    rm -f ${D}${bindir}/c_rehash
    rm -rf ${D}${libdir}/ssl-3/misc
}
