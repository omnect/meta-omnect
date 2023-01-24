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
    file://redundant-env-fragment.cfg \
    file://silent_console.cfg \
"

# copy configuration fragment from template, before SRC_URI is checked
do_fetch:prepend() {
    import os
    cfg_file = d.getVar('OMNECT_THISDIR_SAVED', True) + d.getVar('PN', True) + "/" + "redundant-env-fragment.cfg"
    cfg_file_template = cfg_file + ".template"
    os.system("cp " + cfg_file_template + " " + cfg_file)
}

inherit omnect_fw_env_config

# incorporate distro configuration in redundant-env-fragment.cfg
do_configure:prepend() {
    local cfg_frag=${OMNECT_THISDIR_SAVED}${PN}/redundant-env-fragment.cfg
    local env_size=$(omnect_conv_size_param "${OMNECT_PART_SIZE_UBOOT_ENV}"    "u-boot env. size")
    local  offset1=$(omnect_conv_size_param "${OMNECT_PART_OFFSET_UBOOT_ENV1}" "u-boot env. offset1")
    local  offset2=$(omnect_conv_size_param "${OMNECT_PART_OFFSET_UBOOT_ENV2}" "u-boot env. offset2")

    sed -i -e "s|^CONFIG_ENV_SIZE=.*$|CONFIG_ENV_SIZE=${env_size}|g" ${cfg_frag}
    sed -i -e "s|^CONFIG_ENV_OFFSET=.*$|CONFIG_ENV_OFFSET=${offset1}|g" ${cfg_frag}
    sed -i -e "s|^CONFIG_ENV_OFFSET_REDUND=.*$|CONFIG_ENV_OFFSET_REDUND=${offset2}|g" ${cfg_frag}

    # for devtool
    if [ -d "${S}/oe-local-files/" ]; then cp ${cfg_frag} ${S}/oe-local-files/; fi
}
