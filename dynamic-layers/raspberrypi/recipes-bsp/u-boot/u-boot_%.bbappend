FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://rpi-always-set-fdt_addr-with-firmware-provided-FDT-address.patch \
    file://set-config_mmc_env_dev.patch \
"

SRC_URI:append:raspberrypi4-64 = "\
    file://set-config-bcm2711.cfg \
    file://add-reset-info.patch \
    file://enable-reset-info-cmd-fragment.cfg \
"
