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
#   EM7455 as used in the test farm.
#   As a workaround disable USB in U-Boot (for our rpi4 test device only) as we
#   don't currently need it for booting. A question was sent to the U-Boot
#   mailing list concerning this problem, maybe future versions are capable of
#   handling that.
SRC_URI:append:rpi4-omnect-lab = "\
    file://disable-usb.cfg \
"

# Appends a string to the name of the local version of the U-Boot image; e.g. "-1"; if you like to update the bootloader via
# swupdate and iot-hub-device-update, the local version must be increased;
UBOOT_LOCALVERSION = "-2"
PKGV = "${PV}${UBOOT_LOCALVERSION}"

do_configure:prepend() {
    cp -f ${WORKDIR}/omnect_env_rpi.h ${S}/include/configs/omnect_env_machine.h
}

do_deploy:append() {
  echo "${PKGV}" > ${DEPLOYDIR}/bootloader_version
}
