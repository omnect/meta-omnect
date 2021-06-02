FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-5.4:"
SRC_URI += "\
    file://overlayfs.cfg \
    file://systemd_recommends.cfg \
"
