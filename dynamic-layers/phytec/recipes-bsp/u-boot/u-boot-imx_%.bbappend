FILESEXTRAPATHS:prepend := "${THISDIR}/u-boot:${LAYERDIR_omnect}/recipes-bsp/u-boot/u-boot:${LAYERDIR_core}/recipes-bsp/u-boot/files:"

SRC_URI += " \
    file://add-reset-info.patch \
    file://omnect_env.patch \
    file://phycore-imx8mm_defconfig.patch \
    file://silent_console_early.patch \
    file://disable_android_boot_image.cfg \
    file://disable-nfs.cfg \
    file://disable-usb.cfg \
    file://enable_generic_console_fs_cmds.cfg \
    file://enable-reset-info-cmd-fragment.cfg \
    file://enable-pxe-cmd.cfg \
    file://lock-env.cfg \
    file://redundant-env.cfg \
    file://reloc_gd_env.cfg \
    file://silent_console.cfg \
    file://omnect_env.h \
    file://omnect_env_phycore_imx8mm.h \
"

# cve patches from openembedded-core u-boot recipe
SRC_URI += " \
    file://0001-i2c-fix-stack-buffer-overflow-vulnerability-in-i2c-m.patch \
"

CVE_PRODUCT = "u-boot-imx u-boot"

inherit omnect_uboot_configure_env omnect_bootloader


do_configure:prepend:mx8mm-nxp-bsp() {
    cp -f ${WORKDIR}/omnect_env_phycore_imx8mm.h ${S}/include/configs/omnect_env_machine.h
}
