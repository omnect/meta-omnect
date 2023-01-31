FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "${@bb.utils.contains('OMNECT_RELEASE_IMAGE', '1', 'file://release_log_level.patch', '', d)}"
