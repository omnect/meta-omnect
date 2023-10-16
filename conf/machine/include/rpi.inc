PREFERRED_PROVIDER_virtual/bootloader = "u-boot"

# mask u_boot bbappend from meta-raspberrypi, we handle fw_env.conf in swupdates libubootenv
BBMASK += "/meta-raspberrypi/recipes-bsp/u-boot/u-boot_%.bbappend"

# u-boot to be able to switch between A/B updates
RPI_USE_U_BOOT = "1"

# enable serial interface
ENABLE_UART = "${@bb.utils.contains('OMNECT_RELEASE_IMAGE', '1', '0', '1', d)}"

# initramfs type
OMNECT_INITRAMFS_FSTYPE = "cpio.gz.u-boot"

# overwrite CMDLINE_ROOTFS from meta-raspberrypi, we set "root" in boot.scr
CMDLINE_ROOTFS = ""

# u-boot config vars
UBOOT_FDT_ADDR = "fdt_addr"

# ethernet device name
OMNECT_ETH0 = "eth0"

# wlan device name
OMNECT_WLAN0 = "wlan0"

# configure hardware watchdog
# the maximum watchdog deadline depends on the hardware capabilities
SYSTEMD_RuntimeWatchdogSec  = "15"
SYSTEMD_RebootWatchdogSec   = "15"

# this machine uses uboot
MACHINEOVERRIDES:prepend = "omnect_uboot:"
