# openssl-misc is dropped from PACKAGES (see omnect-os-distro.conf) to keep perl
# out of the image. That only removes the package, not its files - they end up in
# the main openssl package instead. c_rehash and the misc scripts are perl, so
# they cannot run in an image without an interpreter.
do_install:append:class-target() {
    rm -f ${D}${bindir}/c_rehash
    rm -rf ${D}${libdir}/ssl-3/misc
}
