FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://Fix-inappropriate-fifo-truncate.patch"

# ignore patch-status in do_patch_qa
ERROR_QA:remove = "patch-status"
