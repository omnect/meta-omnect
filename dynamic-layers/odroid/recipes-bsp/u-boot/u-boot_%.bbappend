FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://enable_mmc_env.patch \
    file://mmc_env.cfg \
    file://mmc_env_sdcard.cfg \
"

UBOOT_ENV = ""
