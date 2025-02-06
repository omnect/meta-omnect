FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

DEPENDS += "bc-native"

SRC_URI += "\
    file://omnect_env.patch \
    file://boot_retry.cfg \
    file://do_not_use_default_bootcommand.cfg \
    file://disable-nfs.cfg \
    file://lock-env.cfg \
    file://reloc_gd_env.cfg \
    file://silent_console.cfg \
    file://omnect_env.h \
    file://omnect_env.env \
"

# Note:
#   U-Boot might crash if a USB endpoint is in state halted during enumeration,
#   and unfortunately this is the case with the LTE modem Sierra Wireless
#   AirPrime EM7455 attached to an RPI 4 as recently used in the test farm.
#   As a workaround disable USB in U-Boot as we don't currently need it for
#   booting and would generally rule out any interference with attached devices.
#   A question was sent to the U-Boot mailing list concerning this problem,
#   maybe future versions are capable of handling that.
SRC_URI:append = "\
    file://disable-usb.cfg \
"

inherit omnect_uboot_configure_env omnect_bootloader

# ignore patch-status in do_patch_qa
ERROR_QA:remove = "patch-status"
