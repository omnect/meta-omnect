FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://Fix-inappropriate-fifo-truncate.patch"

do_install:append() {
    if ${@bb.utils.contains('OMNECT_RELEASE_IMAGE', '1', 'true', 'false', d)}; then
        echo "DROPBEAR_EXTRA_ARGS=\"-s -w\"" >  ${D}${sysconfdir}/default/dropbear
    fi
}
