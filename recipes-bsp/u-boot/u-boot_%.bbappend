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
    file://redundant-env-fragment.cfg \
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

# since bootloader version gets embedded in bootloader file also general
# settings thereof need to be fed into checksumming
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR}/conf/distro/include/omnect-os-bootloader-version.conf"

OMNECT_BOOTLOADER_CHECKSUM_FILES_GLOB_IGNORE = "${OMNECT_THISDIR_SAVED}/u-boot/.gitignore"
# don't include files which are generated on build:
OMNECT_BOOTLOADER_CHECKSUM_FILES_GLOB_IGNORE += "${OMNECT_THISDIR_SAVED}/u-boot/redundant-env-fragment.cfg"


# copy configuration fragment from template, before SRC_URI is checked
do_fetch:prepend() {
    import os
    cfg_file = d.getVar('OMNECT_THISDIR_SAVED', True) + d.getVar('PN', True) + "/" + "redundant-env-fragment.cfg"
    cfg_file_template = cfg_file + ".template"
    os.system("cp " + cfg_file_template + " " + cfg_file)
}

inherit omnect_bootloader_versioning
inherit omnect_fw_env_config
inherit omnect_uboot_configure_env

do_configure:prepend() {
    # incorporate distro configuration in redundant-env-fragment.cfg
    local cfg_frag=${OMNECT_THISDIR_SAVED}${PN}/redundant-env-fragment.cfg
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
