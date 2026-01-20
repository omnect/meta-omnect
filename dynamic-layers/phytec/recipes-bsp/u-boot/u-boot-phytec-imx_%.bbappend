FILESEXTRAPATHS:prepend := "${THISDIR}/u-boot:${LAYERDIR_omnect}/recipes-bsp/u-boot/u-boot:${LAYERDIR_core}/recipes-bsp/u-boot/files:"

SRC_URI += " \
    file://add-reset-info.patch \
    file://omnect_env.patch \
    file://silent_console_early.patch \
    file://boot_retry.cfg \
    file://disable_android_boot_image.cfg \
    file://disable-nfs.cfg \
    file://disable-squashfs.cfg \
    file://disable-usb.cfg \
    file://do_not_use_default_bootcommand.cfg \
    file://enable-gpt.cfg \
    file://enable_dm_rng.cfg \
    file://enable_generic_console_fs_cmds.cfg \
    file://enable-reset-info-cmd-fragment.cfg \
    file://enable-pxe-cmd.cfg \
    file://lock-env.cfg \
    file://redundant-env.cfg \
    file://reloc_gd_env.cfg \
    file://silent_console.cfg \
    file://omnect_env.h \
    file://omnect_env_phycore_imx8mm.h \
    file://omnect_env.env \
    file://phycore_imx8mm.env \
"

CVE_PRODUCT = "u-boot-phytec-imx u-boot"
CVE_VERSION = "${@d.getVar("PV").split('-')[0]}"

OMNECT_BOOTLOADER_CHECKSUM_FILES = "${OMNECT_BOOTLOADER_RECIPE_PATH}"

inherit omnect_uboot_configure_env omnect_bootloader

do_configure:prepend:mx8mm-nxp-bsp() {
    cp -f ${WORKDIR}/omnect_env_phycore_imx8mm.h ${S}/include/configs/omnect_env_machine.h
    cp -f ${WORKDIR}/phycore_imx8mm.env ${S}/board/phytec/phycore_imx8mm/phycore_imx8mm.env
}
