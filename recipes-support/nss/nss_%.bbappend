# nss packages the whole ${bindir}, so its test and demo tools ship in the image.
# Drop the ones that only exist for testing, plus smime, which is perl and has no
# interpreter in the image (nss-smime is dropped from PACKAGES in
# omnect-os-distro.conf, which leaves the file in the main package).
do_install:append:class-target() {
    rm -f ${D}${bindir}/bltest \
          ${D}${bindir}/dbtool \
          ${D}${bindir}/ecperf \
          ${D}${bindir}/fipstest \
          ${D}${bindir}/smime
}
