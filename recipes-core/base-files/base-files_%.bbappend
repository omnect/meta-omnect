FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

do_install_append() {
    sed -i "s#@@ROOT_DEV_P@@#${ROOT_DEV_P}#" ${D}${sysconfdir}/fstab
}
