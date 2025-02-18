FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-Fix-device-dependency-in-hciuart.service.patch \
file://hciuart_restart.patch"
