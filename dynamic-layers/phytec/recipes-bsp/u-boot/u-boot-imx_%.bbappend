FILESEXTRAPATHS:prepend := "${THISDIR}/u-boot:"
SRC_URI += "\
    file://enable_boot_script.patch\
    file://enable_generic_console_fs_cmds.cfg\
"

check_config_value() {
    local ics_dm_val="$1"
    local uboot_conf_var="$2"

    ics_dm_val="$(echo "${ics_dm_val} * 1024" | bc)" # multiply with 1024
    uboot_conf_val=$(grep "^${uboot_conf_var}=" ${S}/phycore-imx8mm_defconfig/.config | awk -F '=' '{print $2}')
    uboot_conf_val="$(printf '%d' ${uboot_conf_val})" # convert to decimal
    if [ ${uboot_conf_val} -ne ${ics_dm_val} ]; then
        bbfatal "mismatch for ${uboot_conf_var}: ${ics_dm_val} <-> ${uboot_conf_val}"
    fi
}

do_configure:append:phytec-imx8mm() {
    check_config_value "${@d.getVar('ICS_DM_PART_OFFSET_UBOOT_ENV1')}" CONFIG_ENV_OFFSET
    check_config_value "${@d.getVar('ICS_DM_PART_OFFSET_UBOOT_ENV2')}" CONFIG_ENV_OFFSET_REDUND
    check_config_value "${@d.getVar('ICS_DM_PART_SIZE_UBOOT_ENV')}"    CONFIG_ENV_SIZE
}
