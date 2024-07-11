FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

DEPENDS += "bc-native"

# THISDIR is only save during recipe parsing
OMNECT_THISDIR_SAVED := "${THISDIR}/"

# At bootm compile time, the CONFIG_SYS_BOOTM_LEN setting from the soc config
# is not honored. E.g. rpi.h sets 64M, but bootm refuses to boot an image with
# 9MB. This patch isn't a real fix, it is a workaround because the soc config
# setting is still not honored.
SRC_URI += "file://bootm_len_check.patch"

SRC_URI += "\
    file://lock-env.cfg \
    file://reloc_gd_env.cfg \
    file://silent_console.cfg \
    file://omnect_env.h \
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

# we do not include u-boot upstream recipe, because
# updates in openembedded_core should be handled by `PV` increase
OMNECT_BOOTLOADER_CHECKSUM_FILES = "${OMNECT_THISDIR_SAVED}/u-boot_%.bbappend"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${OMNECT_THISDIR_SAVED}/u-boot-scr.bb"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${OMNECT_THISDIR_SAVED}/u-boot/*"

# since bootloader version gets embedded in bootloader file also
# settings thereof need to be fed into checksumming
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/classes/omnect_uboot_embedded_version.bbclass"

OMNECT_BOOTLOADER_CHECKSUM_FILES_GLOB_IGNORE = "${OMNECT_THISDIR_SAVED}/u-boot/.gitignore"
# don't include files which are generated on build:
OMNECT_BOOTLOADER_CHECKSUM_FILES_GLOB_IGNORE += "${OMNECT_THISDIR_SAVED}/u-boot/redundant-env-fragment.cfg"

inherit omnect_bootloader_versioning
inherit omnect_uboot_configure_env
