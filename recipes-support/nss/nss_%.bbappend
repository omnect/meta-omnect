# nss packages the whole bindir, but the image uses none of the tools. Keep
# shlibsign, which the postinst needs if it runs on first boot, and move the rest
# into a package that is not installed.
PACKAGES:append:class-target = " ${PN}-tools"

FILES:${PN}:class-target = " \
    ${sysconfdir} \
    ${bindir}/shlibsign \
    ${libdir}/lib*.chk \
    ${libdir}/lib*.so \
"
FILES:${PN}-tools = "${bindir}"
