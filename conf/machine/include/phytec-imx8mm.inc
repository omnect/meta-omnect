require conf/machine/include/phytec-imx8mm_bootloader_embedded_version.inc

# WIC config
WKS_FILE = "omnect-os.phytec.wks.in"
WKS_FILES:${MACHINE} = "${WKS_FILE}"
# don't use class wic-helper from meta-phytec
IMAGE_CLASSES:remove = " wic-helper wic-imx8-helper"

# don't install imx-m4-demos
MACHINE_EXTRA_RRECOMMENDS:remove = "imx-m4-demos"

# install kernel-devicetree to 'root' partition instead of 'boot'
IMAGE_BOOT_FILES:remove:pn-omnect-os-image = " \
    ${KERNEL_DEVICETREE_FN} \
    oftree \
    bootenv.txt \
"
IMAGE_INSTALL:append:pn-omnect-os-image = " kernel-devicetree"
# Todo add 'oftree' to rootfs?

# initramfs type
OMNECT_INITRAMFS_FSTYPE = "cpio.gz.u-boot"

# Set Serial console
SERIAL_CONSOLES ="${@bb.utils.contains('OMNECT_RELEASE_IMAGE', '1', '', '115200;ttymxc2', d)}"
#bootargs console is not part of the devictree, so we have to append it to kernel commandline
APPEND += "console=ttymxc2,115200"

# https://github.com/phytec/meta-phytec/commit/6d71e11b4fc1ee8196e579e4de73ed3197e0e4be
APPEND += "clk-imx8mm.mcore_booted"

# u-boot boot.scr config
KERNEL_BOOTCMD = "booti"
UBOOT_ARCH = "arm64"
UBOOT_FDT_ADDR = "fdt_addr"
UBOOT_FDT_LOAD = "1"
PREFERRED_PROVIDER_u-boot-mkenvimage-native = "u-boot-imx-tools-native"

# redundant u-boot env
# This is currently preset by meta-phytec, because we use u-boot-imx instead
# of our patched u-boot here.
OMNECT_PART_OFFSET_UBOOT_ENV1 = "3840"
OMNECT_PART_OFFSET_UBOOT_ENV2 = "3968"
OMNECT_PART_SIZE_UBOOT_ENV = "64"
# for flash-mode and wic image
OMNECT_PART_OFFSET_BOOT = "4096"

# mask fw_env.config configuration of meta-phytec, we generate that ourselves
BBMASK:append = " meta-phytec/recipes-bsp/u-boot/libubootenv_%.bbappend"

# mask otherwise we can not use the latest meta-freescale/meta-imx commits
BBMASK:append = " meta-imx/meta-bsp/recipes-support/opencv/opencv_4.6.0.imx.bb"
BBMASK:append = " meta-imx/meta-sdk/dynamic-layers/openembedded-layer/recipes-multimedia/dvb-apps/dvb-apps_%.bbappend"

# fix search path
FILESEXTRAPATHS:prepend:pn-imx-boot-phytec := "${LAYERDIR_freescale-layer}/recipes-bsp/imx-mkimage/files:"

# configure hardware watchdog
# the maximum watchdog deadline depends on the hardware capabilities
SYSTEMD_RuntimeWatchdogSec  = "60"
SYSTEMD_RebootWatchdogSec   = "60"

# this machine uses uboot
MACHINEOVERRIDES:prepend = "omnect_uboot:"
MACHINEOVERRIDES:append = ":phytec-imx8mm"

# For now remove optee from MACHINE_FEATURES. We don't support secure boot at
# the moment and tee-supplicant will fail, because we don't boot with the
# appropriate device-tree.
# Furthermore we remove feature nxp8987 (set by meta-imx), because
# tauri-l and polis don't have this chip.
MACHINE_FEATURES:remove = " \
    nxp8987 \
    optee \
"

OMNECT_BOOTLOADER = "u-boot-imx"
# force bootloader version checksum to be old, when sure it's 100% binary compatible
# OMNECT_BOOTLOADER_CHECKSUM_COMPATIBLE:pn-u-boot-imx = "<newchecksum> <oldchecksum>"
# e.g.:
# OMNECT_BOOTLOADER_CHECKSUM_COMPATIBLE:pn-u-boot-imx = "2cf3dd5f692d9ed563f06ecf80d0cb566ddc165fa01a37b4eba663dc7b7b9087 ebe0e595a3efb112b7495a14f9562d89d00041390f26a9ad4985435687bf2311"
#
# OMNECT_BOOTLOADER_CHECKSUM_EXPTECTED:pn-u-boot-imx - build will fail, if the
# computed checksum is different to this; set to <oldchecksum> when
# OMNECT_BOOTLOADER_CHECKSUM_COMPATIBLE:pn-u-boot-imx is set
OMNECT_BOOTLOADER_CHECKSUM_EXPECTED:pn-u-boot-imx = "f2815f386d14e574652fe052365e8ef3de76b21bf1a7f4df45473e5f311fc00f"
OMNECT_BOOTLOADER_CHECKSUM_COMPATIBLE:pn-u-boot-imx = "c60d595748042c46af7fd9de08924b9e3509068944a633571f178790e1909e9b f2815f386d14e574652fe052365e8ef3de76b21bf1a7f4df45473e5f311fc00f"
