FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# TODO: remove me, as soon as the recipe is past 1.24.2 and carries the fix
SRC_URI += "file://0001-broadband-modem-mbim-initialize-autofreed-string-to-N.patch"
