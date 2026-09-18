# runtests.pl in nspr-dev is the only file that makes the package need perl, and
# the tests are never run on a device. The recipe drops compile-et.pl from bindir
# for the same reason.
do_install:append:class-target() {
    rm -f ${D}${libdir}/nspr/tests/runtests.pl
}
