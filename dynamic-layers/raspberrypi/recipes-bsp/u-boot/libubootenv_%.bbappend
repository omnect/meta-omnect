FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://fw_env.config"

DEPENDS += "u-boot-default-script"

do_install_append() {
	rm -rf ${D}${sysconfdir}/fw_env.config
	install -m 0644 -D ${WORKDIR}/fw_env.config ${D}${sysconfdir}/fw_env.config
}
