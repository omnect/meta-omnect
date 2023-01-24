FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://rpi-always-set-fdt_addr-with-firmware-provided-FDT-address.patch \
    file://set-config_mmc_env_dev.patch \
    ${@bb.utils.contains('OMNECT_RELEASE_IMAGE', '1', 'file://silent_console.patch', '', d)} \
"

SRC_URI:append:raspberrypi4-64 = "\
    file://add-reset-info.patch \
    file://enable-reset-info-cmd-fragment.cfg \
"
