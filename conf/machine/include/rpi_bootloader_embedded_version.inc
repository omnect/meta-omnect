# definitions to embed bootloader version in binary
OMNECT_BOOTLOADER_EMBEDDED_VERSION_BBTARGET  = "virtual/bootloader"
OMNECT_BOOTLOADER_EMBEDDED_VERSION_BBFILE    = "u-boot.bin"
OMNECT_BOOTLOADER_EMBEDDED_VERSION_TYPE      = "file"
OMNECT_BOOTLOADER_EMBEDDED_VERSION_PARAMSIZE ?= "256"
OMNECT_BOOTLOADER_EMBEDDED_VERSION_LOCATION  = "/boot/kernel8.img"

IMAGE_BOOT_FILES:remove:omnect_uboot = "u-boot.bin;kernel8.img"
IMAGE_BOOT_FILES:append:omnect_uboot = " bootloader.versioned.bin;kernel8.img"
