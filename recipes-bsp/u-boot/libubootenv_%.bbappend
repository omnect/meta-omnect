# fw_setenv calls fsync() in the case of changed u-boot environment
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += "\
    file://always-fsync-file-writes.patch \
"
