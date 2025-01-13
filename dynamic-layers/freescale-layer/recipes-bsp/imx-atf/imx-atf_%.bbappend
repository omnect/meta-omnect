FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "${@bb.utils.contains('OMNECT_RELEASE_IMAGE', '1', 'file://release_log_level.patch', '', d)}"

ATF_DEBUG = "${@bb.utils.contains('OMNECT_RELEASE_IMAGE', '1', '0', '1', d)}"
OUTPUT_FOLDER ?= "${@bb.utils.contains('OMNECT_RELEASE_IMAGE', '1', 'release', 'debug', d)}"

EXTRA_OEMAKE += " \
	V=1 \
	CRASH_REPORTING=1 \
"

do_deploy:append() {
    install -Dm 0644 ${S}/build/${ATF_PLATFORM}/${OUTPUT_FOLDER}/bl31.bin ${DEPLOYDIR}/imx-boot-tools/bl31-${ATF_PLATFORM}.bin
}
