FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://rpi-always-set-fdt_addr-with-firmware-provided-FDT-address.patch \
"
