require rpi_firmware_settings.inc
require rpi_bootloader_embedded_version.inc

PREFERRED_PROVIDER_virtual/bootloader = "u-boot"
# since u-boot is a file for rpi devices and part of IMAGE_BOOT_FILES, it is not in rootfs
# and not referenced in the wks file
# -> so it doesn't get added to dependency-track sbom
# we add an extra image dependency in this case
DEPENDS:pn-omnect-os-image:append = " virtual/bootloader"

# mask u_boot bbappend from meta-raspberrypi, we handle fw_env.conf in swupdates libubootenv
BBMASK += "/meta-raspberrypi/recipes-bsp/u-boot/u-boot_%.bbappend"

# u-boot to be able to switch between A/B updates
RPI_USE_U_BOOT = "1"

# initramfs type
OMNECT_INITRAMFS_FSTYPE = "cpio.gz.u-boot"

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

OMNECT_BOOTLOADER="u-boot"
# force bootloader version checksum to be old, when sure it's 100% binary compatible
# OMNECT_BOOTLOADER_CHECKSUM_COMPATIBLE:pn-u-boot = "<newchecksum> <oldchecksum>"
# e.g.:
# OMNECT_BOOTLOADER_CHECKSUM_COMPATIBLE:pn-u-boot = "2cf3dd5f692d9ed563f06ecf80d0cb566ddc165fa01a37b4eba663dc7b7b9087 ebe0e595a3efb112b7495a14f9562d89d00041390f26a9ad4985435687bf2310"
#
# OMNECT_BOOTLOADER_CHECKSUM_EXPTECTED:pn-u-boot - build will fail, if the
# computed checksum is different to this; set to <oldchecksum> when
# OMNECT_BOOTLOADER_CHECKSUM_COMPATIBLE:pn-u-boot is set
OMNECT_BOOTLOADER_CHECKSUM_EXPECTED:pn-u-boot = "1d60ada24fab47802ee121847ccef3996fbcdab11bb9a00dd47c19da58f76bf9"
