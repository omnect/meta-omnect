DEPENDS += "u-boot-default-script"
inherit ics_dm_fw_env_config

do_install_append() {
    ics_dm_generate_fw_env_config
}
