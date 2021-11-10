FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

DEPENDS += "bc-native"

# THISDIR is only save during recipe parsing
ICS_DM_THISDIR_SAVED := "${THISDIR}/"

# At bootm compile time, the CONFIG_SYS_BOOTM_LEN setting from the soc config
# is not honored. E.g. rpi.h sets 64M, but bootm refuses to boot an image with
# 9MB. This patch isn't a real fix, it is a workaround because the soc config
# setting is still not honored.
SRC_URI += "file://bootm_len_check.patch"

# enable redundant u-boot environment
SRC_URI += "file://redundant-env-fragment.cfg \
            file://set-config_mmc_env_dev.patch"

# multiply with 1024; convert to hex
ics_dm_conv_param() {
    local param="$1"
    param="$(echo "${param} * 1024" | bc)"
    param="0x$(printf '%x' ${param})"
    echo ${param}
}

# incorporate distro configuration in redundant-env-fragment.cfg
do_configure_prepend() {
    local cfg_frag=${ICS_DM_THISDIR_SAVED}${PN}/redundant-env-fragment.cfg
    local env_size=$(ics_dm_conv_param ${ICS_DM_PART_SIZE_UBOOT_ENV})
    local  offset1=$(ics_dm_conv_param ${ICS_DM_PART_OFFSET_UBOOT_ENV1})
    local  offset2=$(ics_dm_conv_param ${ICS_DM_PART_OFFSET_UBOOT_ENV2})

    sed -i -e "s|^CONFIG_ENV_SIZE=.*$|CONFIG_ENV_SIZE=${env_size}|g" ${cfg_frag}
    sed -i -e "s|^CONFIG_ENV_OFFSET=.*$|CONFIG_ENV_OFFSET=${offset1}|g" ${cfg_frag}
    sed -i -e "s|^CONFIG_ENV_OFFSET_REDUND=.*$|CONFIG_ENV_OFFSET_REDUND=${offset2}|g" ${cfg_frag}
}
