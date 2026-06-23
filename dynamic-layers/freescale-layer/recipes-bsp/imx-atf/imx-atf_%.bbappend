FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "${@bb.utils.contains('OMNECT_RELEASE_IMAGE', '1', 'file://release_log_level.patch', '', d)}"

# wrynose meta-imx selects the ATF debug build via PACKAGECONFIG[debug]=DEBUG=1,
# not the old ATF_DEBUG var; enable it for dev images so build/<plat>/debug exists.
PACKAGECONFIG:append = "${@bb.utils.contains('OMNECT_RELEASE_IMAGE', '1', '', ' debug', d)}"
OUTPUT_FOLDER ?= "${@bb.utils.contains('OMNECT_RELEASE_IMAGE', '1', 'release', 'debug', d)}"

EXTRA_OEMAKE += " \
	V=1 \
	CRASH_REPORTING=1 \
"

do_deploy:append() {
    install -Dm 0644 ${S}/build/${ATF_PLATFORM}/${OUTPUT_FOLDER}/bl31.bin ${DEPLOYDIR}/imx-boot-tools/bl31-${ATF_PLATFORM}.bin
}
