# definitions to embed bootloader version in binary
OMNECT_BOOTLOADER_EMBEDDED_VERSION_BBTARGET    = "imx-boot-phytec"
OMNECT_BOOTLOADER_EMBEDDED_VERSION_BINFILE     = "${IMAGE_BOOTLOADER}"
OMNECT_BOOTLOADER_EMBEDDED_VERSION_TYPE        = "flash"
OMNECT_BOOTLOADER_EMBEDDED_VERSION_PARAMSIZE   ?= "256"
OMNECT_BOOTLOADER_EMBEDDED_VERSION_IMAGEOFFSET = "${@${BOOTLOADER_SEEK} * 1024}"
OMNECT_BOOTLOADER_EMBEDDED_VERSION_IMAGESIZE   = "${@${OMNECT_PART_OFFSET_UBOOT_ENV1} * 1024 - ${OMNECT_BOOTLOADER_EMBEDDED_VERSION_IMAGEOFFSET}}"
OMNECT_BOOTLOADER_EMBEDDED_VERSION_IMAGEGZ     = "1"
