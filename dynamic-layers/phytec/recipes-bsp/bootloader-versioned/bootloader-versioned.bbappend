# THISDIR is only save during recipe parsing
OMNECT_THISDIR_SAVED := "${THISDIR}/"

OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/classes/u-boot-scr.bbclass"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/recipes-bsp/u-boot/u-boot-scr.bb"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/recipes-bsp/u-boot/u-boot/*"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/conf/machine/include/phytec-imx8mm_bootloader_embedded_version.inc"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_phytec}/recipes-bsp/u-boot/u-boot-*.inc"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_core}/recipes-bsp/u-boot/u-boot.inc"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${OMNECT_THISDIR_SAVED}/../u-boot/u-boot-imx_%.bbappend"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${OMNECT_THISDIR_SAVED}/../u-boot/u-boot/*"
# imx-atf and u-boot are part of imx-boot(-phytec). (tbd: imx-boot(-phytec) recipe
# is more or less copying thus currently not reflected here.)
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_phytec}/dynamic-layers/fsl-bsp-release/recipes-bsp/imx-atf/imx-atf_2.10.bbappend"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/dynamic-layers/freescale-layer/recipes-bsp/imx-atf/imx-atf/*"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_fsl-bsp-release}/recipes-bsp/imx-atf/imx-atf_*.bb"

# since bootloader version gets embedded in bootloader file also
# settings thereof need to be fed into checksumming
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/classes/omnect_uboot_embedded_version.bbclass"

OMNECT_BOOTLOADER_CHECKSUM_FILES_GLOB_IGNORE = "${LAYERDIR_omnect}/recipes-bsp/u-boot/.gitignore"
# we don't use rauc and overwrite the u-boot env with omnect_env.patch
OMNECT_BOOTLOADER_CHECKSUM_FILES_GLOB_IGNORE += "${LAYERDIR_phytec}/recipes-bsp/u-boot/u-boot-rauc.inc"


##TODO:
