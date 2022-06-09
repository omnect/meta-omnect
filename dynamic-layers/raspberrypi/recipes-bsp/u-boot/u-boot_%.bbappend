FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# kirkstone: for raspberrypi4-64, enforce rpi_4_config configuration, instead of generic arm64
#     (see machine configuration meta-raspberrypi/conf/machine/raspberrypi4-64.conf)
UBOOT_MACHINE:raspberrypi4-64 = "rpi_4_config"

SRC_URI += "\
    file://rpi-always-set-fdt_addr-with-firmware-provided-FDT-address.patch \
    file://set-config_mmc_env_dev.patch \
"

SRC_URI:append:raspberrypi4-64 = "\
    file://add-reset-info.patch \
    file://enable-reset-info-cmd-fragment.cfg \
"
