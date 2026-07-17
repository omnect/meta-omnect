# apparmor's do_install hardcodes perl artifacts in two spots: a sed on the SWIG
# wrapper (libraries/libapparmor/swig/perl/libapparmor_wrap.c) and a find under
# ${libdir}/perl5. We build --without-perl (PACKAGECONFIG:remove:pn-apparmor = "perl"
# in omnect-os-distro.conf), so neither path exists and both commands abort do_install.
# Create the paths in :prepend so both no-op; with --without-perl nothing is built or
# installed into them, and the empty perl5 dir is not packaged (no FILES entry).
do_install:prepend() {
    if ! ${@bb.utils.contains('PACKAGECONFIG', 'perl', 'true', 'false', d)}; then
        install -d ${B}/libraries/libapparmor/swig/perl ${D}${libdir}/perl5
        [ -e ${B}/libraries/libapparmor/swig/perl/libapparmor_wrap.c ] || \
            : > ${B}/libraries/libapparmor/swig/perl/libapparmor_wrap.c
    fi
}
