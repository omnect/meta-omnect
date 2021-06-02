# u-boot to be able to switch between A/B updates
RPI_USE_U_BOOT = "1"

WKS_FILE = "sdcard.wks.in"

# install kernel to rootfs and remove it from boot partition
CORE_IMAGE_EXTRA_INSTALL += "kernel-image"
IMAGE_BOOT_FILES_remove = "Image"

# for referencing the root device in fstab, uboot, and swupdate sw-description
ROOT_DEV = "/dev/mmcblk0"
ROOT_DEV_P = "/dev/mmcblk0p"

# mask u_boot bbappend from meta-raspberrypi, we handle fw_env.conf in swupdates libubootenv
BBMASK += "/meta-raspberrypi/recipes-bsp/u-boot/u-boot_%.bbappend"
