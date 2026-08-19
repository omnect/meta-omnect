# nss packages the whole bindir; drop the test tools and the perl script smime.
do_install:append:class-target() {
    rm -f ${D}${bindir}/bltest \
          ${D}${bindir}/dbtool \
          ${D}${bindir}/ecperf \
          ${D}${bindir}/fipstest \
          ${D}${bindir}/smime
}
