PREFERRED_PROVIDER_virtual/bootloader = "u-boot"

# mask u_boot bbappend from meta-raspberrypi, we handle fw_env.conf in swupdates libubootenv
BBMASK += "/meta-raspberrypi/recipes-bsp/u-boot/u-boot_%.bbappend"

# u-boot to be able to switch between A/B updates
RPI_USE_U_BOOT = "1"

# enable serial interface
ENABLE_UART = "1"

# initramfs type
OMNECT_INITRAMFS_FSTYPE = "cpio.gz.u-boot"

# build cmdline.txt
# overwrite CMDLINE_ROOTFS from meta-raspberrypi, we set "root" in boot.scr
CMDLINE_ROOTFS = ""
DISABLE_RPI_BOOT_LOGO = "1"
# prepend before uart console to prioritize serial console output of stdout
CMDLINE:prepend:pn-rpi-cmdline = "console=tty0 "

# u-boot config vars
UBOOT_FDT_ADDR = "fdt_addr"

# wlan device name
OMNECT_WLAN0 = "wlan0"

# configure hardware watchdog
# the maximum watchdog deadline depends on the hardware capabilities
SYSTEMD_RuntimeWatchdogSec  = "15"
SYSTEMD_RebootWatchdogSec   = "15"

# this machine uses uboot
MACHINEOVERRIDES:prepend = "omnect_uboot:"
