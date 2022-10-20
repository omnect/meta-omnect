# WIC config
WKS_FILE = "ics-dm-os.phytec.wks.in"
WKS_FILES:${MACHINE} = "${WKS_FILE}"
# don't use class wic-helper from meta-phytec
IMAGE_CLASSES:remove = " wic-helper"

# install kernel-devicetree to 'root' partition instead of 'boot'
IMAGE_BOOT_FILES:remove:pn-ics-dm-os-image = " \
    ${KERNEL_DEVICETREE_FN} \
    oftree \
    bootenv.txt \
"
IMAGE_INSTALL:append:pn-ics-dm-os-image = " kernel-devicetree"
# Todo add 'oftree' to rootfs?

# u-boot boot.scr config
KERNEL_BOOTCMD = "booti"
UBOOT_ARCH = "arm64"
UBOOT_FDT_ADDR = "fdt_addr"
UBOOT_FDT_LOAD = "1"

# redundant u-boot env
# This is currently preset by meta-phytec, because we use u-boot-imx instead
# of our patched u-boot here.
ICS_DM_PART_OFFSET_UBOOT_ENV1 = "3840"
ICS_DM_PART_OFFSET_UBOOT_ENV2 = "3968"
ICS_DM_PART_SIZE_UBOOT_ENV = "64"

# mask fw_env.config configuration of meta-phytec, we generate that ourselves
BBMASK:append = " meta-phytec/recipes-bsp/u-boot/libubootenv_%.bbappend"

# configure hardware watchdog
# the maximum watchdog deadline depends on the hardware capabilities
SYSTEMD_RuntimeWatchdogSec  = "60"
SYSTEMD_RebootWatchdogSec   = "60"
