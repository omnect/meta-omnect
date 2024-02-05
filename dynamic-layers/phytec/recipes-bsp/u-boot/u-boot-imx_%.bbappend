FILESEXTRAPATHS:prepend := "${THISDIR}/u-boot:${LAYERDIR_omnect}/recipes-bsp/u-boot/u-boot:"

# THISDIR is only save during recipe parsing
OMNECT_THISDIR_SAVED := "${THISDIR}/"

SRC_URI += " \
    file://add-reset-info.patch \
    file://omnect_env.patch \
    file://phycore-imx8mm_defconfig.patch \
    file://silent_console_early.patch \
    file://disable_android_boot_image.cfg \
    file://disable-usb.cfg \
    file://enable_generic_console_fs_cmds.cfg \
    file://enable-reset-info-cmd-fragment.cfg \
    file://enable-pxe-cmd.cfg \
    file://lock-env.cfg \
    file://reloc_gd_env.cfg \
    file://silent_console.cfg \
    file://omnect_env.h \
    file://omnect_env_phycore_imx8mm.h \
"

OMNECT_BOOTLOADER_CHECKSUM_FILES  = "${LAYERDIR_omnect}/classes/u-boot-scr.bbclass"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/recipes-bsp/u-boot/u-boot-scr.bb"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/recipes-bsp/u-boot/u-boot/*"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_phytec}/recipes-bsp/u-boot/${PN}_${PV}_*.bb"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_phytec}/recipes-bsp/u-boot/u-boot-*.inc"
# included by "${LAYERDIR_phytec}/recipes-bsp/u-boot/${PN}_${PV}_*.bb" - how do we know it's still the case on update?:
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_core}/recipes-bsp/u-boot/u-boot.inc"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${OMNECT_THISDIR_SAVED}/${PN}_%.bbappend"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${OMNECT_THISDIR_SAVED}/u-boot/*"
# imx-atf and u-boot are part of imx-boot(-phytec). (tbd: imx-boot(-phytec) recipe
# is more or less copying thus currently not reflected here.)
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_phytec}/dynamic-layers/freescale-layer/recipes-bsp/imx-atf/imx-atf*.bbappend"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_phytec}/dynamic-layers/freescale-layer/recipes-bsp/imx-atf/files/*"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_fsl-bsp-release}/recipes-bsp/imx-atf/imx-atf_*.bb"

OMNECT_BOOTLOADER_CHECKSUM_FILES_GLOB_IGNORE = "${LAYERDIR_omnect}/recipes-bsp/u-boot/.gitignore"
OMNECT_BOOTLOADER_CHECKSUM_FILES_GLOB_IGNORE += "${LAYERDIR_omnect}/recipes-bsp/u-boot/u-boot/bootm_len_check.patch"
OMNECT_BOOTLOADER_CHECKSUM_FILES_GLOB_IGNORE += "${LAYERDIR_omnect}/recipes-bsp/u-boot/u-boot/redundant-env-fragment.cfg"
OMNECT_BOOTLOADER_CHECKSUM_FILES_GLOB_IGNORE += "${LAYERDIR_omnect}/recipes-bsp/u-boot/u-boot/redundant-env-fragment.cfg.template"
# we don't use rauc and overwrite the u-boot env with omnect_env.patch
OMNECT_BOOTLOADER_CHECKSUM_FILES_GLOB_IGNORE += "${LAYERDIR_phytec}/recipes-bsp/u-boot/u-boot-rauc.inc"

inherit omnect_uboot_configure_env
inherit omnect_bootloader_versioning

do_configure:prepend() {
    omnect_uboot_configure_env
}

do_configure:prepend:mx8mm-nxp-bsp() {
    cp -f ${WORKDIR}/omnect_env_phycore_imx8mm.h ${S}/include/configs/omnect_env_machine.h
}
