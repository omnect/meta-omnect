FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

DEPENDS += "bc-native"

# THISDIR is only save during recipe parsing
OMNECT_THISDIR_SAVED := "${THISDIR}/"

SRC_URI += "\
    file://omnect_env.patch \
    file://boot_retry.cfg \
    file://do_not_use_default_bootcommand.cfg \
    file://lock-env.cfg \
    file://reloc_gd_env.cfg \
    file://silent_console.cfg \
    file://omnect_env.h \
    file://omnect_env.env \
"

OMNECT_UBOOT_TEMPLATED_FRAGMENTS = "${WORKDIR}/redundant-env-fragment.cfg"

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
inherit omnect_fw_env_config
inherit omnect_uboot_configure_env

do_configure:prepend() {
    # copy templated configuration fragments to workspace
    for i in ${OMNECT_UBOOT_TEMPLATED_FRAGMENTS}; do cp ${OMNECT_THISDIR_SAVED}/${PN}/${i##*/} ${WORKDIR}/; done

    # incorporate distro configuration in redundant-env-fragment.cfg
    local cfg_frag=${WORKDIR}/redundant-env-fragment.cfg
    local env_size=$(omnect_conv_size_param "${OMNECT_PART_SIZE_UBOOT_ENV}"    "u-boot env. size")
    local  offset1=$(omnect_conv_size_param "${OMNECT_PART_OFFSET_UBOOT_ENV1}" "u-boot env. offset1")
    local  offset2=$(omnect_conv_size_param "${OMNECT_PART_OFFSET_UBOOT_ENV2}" "u-boot env. offset2")

    sed -i -e "s|^CONFIG_ENV_SIZE=.*$|CONFIG_ENV_SIZE=${env_size}|g" ${cfg_frag}
    sed -i -e "s|^CONFIG_ENV_OFFSET=.*$|CONFIG_ENV_OFFSET=${offset1}|g" ${cfg_frag}
    sed -i -e "s|^CONFIG_ENV_OFFSET_REDUND=.*$|CONFIG_ENV_OFFSET_REDUND=${offset2}|g" ${cfg_frag}

    # for devtool
    if [ -d "${S}/oe-local-files/" ]; then cp ${cfg_frag} ${S}/oe-local-files/; fi

    omnect_uboot_configure_env
}
