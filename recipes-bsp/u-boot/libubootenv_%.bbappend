DEPENDS += "u-boot-default-script"
inherit omnect_fw_env_config

do_install:append:omnect_uboot() {
    omnect_generate_fw_env_config
}
