FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://add-reset-info.patch \
    file://enable-reset-info-cmd-fragment.cfg \
    file://omnect_env.patch \
    file://rpi-always-set-fdt_addr-with-firmware-provided-FDT-address.patch \
    file://omnect_env_rpi.h \
"

# Note:
#   U-Boot crashes if a USB endpoint is in state halted during enumeration, and
#   unfortunately this is the case with the LTE modem Sierra Wireless AirPrime
#   EM7455 as recently used in the test farm.
#   As a workaround disable USB in U-Boot as we don't currently need it for
#   booting and would generally rule out any interference with attached devices.
#   A question was sent to the U-Boot mailing list concerning this problem,
#   maybe future versions are capable of handling that.
SRC_URI:append:raspberrypi4 = "\
    file://disable-usb.cfg \
"

# Appends a string to the name of the local version of the U-Boot image; e.g. "-1"; if you like to update the bootloader via
# swupdate and iot-hub-device-update, the local version must be increased;
#
# Note: `UBOOT_LOCALVERSION` should be also increased on change of variables
#   `APPEND`,
#   `OMNECT_UBOOT_WRITEABLE_ENV_FLAGS`
#
# Note: also changes which affect the content of the boot partition, e.g.
# `CMDLINE_*` in rpi-cmdline.bb should be reflected with an increase of
# `UBOOT_LOCALVERSION` to force an update of the entire bootloader
# (proprietary rpi bootloader + u-boot)
UBOOT_LOCALVERSION = "-5"
PKGV = "${PV}${UBOOT_LOCALVERSION}"

do_configure:prepend() {
    cp -f ${WORKDIR}/omnect_env_rpi.h ${S}/include/configs/omnect_env_machine.h
}

do_deploy:append() {
  echo "${PKGV}" > ${DEPLOYDIR}/bootloader_version
}
