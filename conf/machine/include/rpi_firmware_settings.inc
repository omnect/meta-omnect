# enable serial interface
ENABLE_UART = "1"

# build cmdline.txt
# overwrite CMDLINE_ROOTFS from meta-raspberrypi, we set "root" in boot.scr
CMDLINE_ROOTFS = ""
DISABLE_RPI_BOOT_LOGO = "1"
# prepend before uart console to prioritize serial console output of stdout
CMDLINE:prepend:pn-rpi-cmdline = "console=tty0 "
# prevent state where watchdog is disabled
CMDLINE:append:pn-rpi-cmdline = " bcm2835-wdt.nowayout=1"

# u-boot config vars
UBOOT_FDT_ADDR = "fdt_addr"

# redundant u-boot env
OMNECT_PART_OFFSET_UBOOT_ENV1 = "1024"
OMNECT_PART_OFFSET_UBOOT_ENV2 = "1152"
OMNECT_PART_SIZE_UBOOT_ENV = "64"

# for flash-mode and wic image
OMNECT_PART_OFFSET_BOOT = "2048"
