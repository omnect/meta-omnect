# nss packages the whole bindir, but the image uses none of the tools. Keep
# shlibsign, which the postinst needs if it runs on first boot.
PACKAGES:append:class-target = " ${PN}-tools"

FILES:${PN}:class-target = " \
    ${sysconfdir} \
    ${bindir}/shlibsign \
    ${libdir}/lib*.chk \
    ${libdir}/lib*.so \
"
# PACKAGES order decides who claims a file first: nss takes shlibsign, nss-tools
# the rest of bindir. No file ends up in both.
FILES:${PN}-tools = "${bindir}"
