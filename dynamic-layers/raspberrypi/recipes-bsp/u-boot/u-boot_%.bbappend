FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://rpi-always-set-fdt_addr-with-firmware-provided-FDT-address.patch \
    file://set-config_mmc_env_dev.patch \
    file://omnect_env.patch \
"

SRC_URI:append:raspberrypi4-64 = "\
    file://add-reset-info.patch \
    file://enable-reset-info-cmd-fragment.cfg \
"
