DEPENDS += "u-boot-default-script"
inherit ics_dm_fw_env_config

do_install:append() {
    ics_dm_generate_fw_env_config
}
