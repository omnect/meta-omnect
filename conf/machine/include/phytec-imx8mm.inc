require conf/machine/include/phytec-imx8mm_bootloader_embedded_version.inc

PREFERRED_PROVIDER_virtual/kernel:mx8-nxp-bsp = "linux-phytec-imx"

# WIC config
WKS_FILE = "omnect-os.phytec.wks.in"
WKS_FILES:${MACHINE} = "${WKS_FILE}"
# don't use class wic-helper from meta-phytec
IMAGE_CLASSES:remove = " wic-helper wic-imx8-helper"

# don't install imx-m4-demos
MACHINE_EXTRA_RRECOMMENDS:remove = "imx-m4-demos"

# install kernel-devicetree to 'root' partition instead of 'boot' and only install boot scripts to boot
IMAGE_BOOT_FILES:remove:pn-omnect-os-image = " \
    ${KERNEL_DEVICETREE_FN} \
    boot.scr.uimg \
    fitImage  \
    oftree \
    bootenv.txt \
"

IMAGE_INSTALL:append:pn-omnect-os-image = " kernel-devicetree"

# initramfs type
OMNECT_INITRAMFS_FSTYPE = "cpio.gz.u-boot"

# Set Serial console
SERIAL_CONSOLES ="${@bb.utils.contains('OMNECT_RELEASE_IMAGE', '1', '', '115200;ttymxc2', d)}"
#bootargs console is not part of the devictree, so we have to append it to kernel commandline
APPEND += "console=ttymxc2,115200"

# https://github.com/phytec/meta-phytec/commit/6d71e11b4fc1ee8196e579e4de73ed3197e0e4be
APPEND += "clk-imx8mm.mcore_booted"

# next APPEND options are only needed for reboot reason support
APPEND:append:omnect_pstore = " ramoops.dump_oops=1 ramoops.ecc=1 printk.always_kmsg_dump=Y crash_kexec_post_notifiers=Y"

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

# mask phytecs CVE bbappend handling, which interferes with ours (u-boot-scr matches as well)
BBMASK:append = " meta-phytec/recipes-bsp/u-boot/u-boot-%.bbappend"

# masks necessary to build with our bblayers.conf:
BBMASK:append = " \
    meta-imx/meta-imx-sdk/dynamic-layers/virtualization-layer/recipes-fsl/packagegroup/packagegroup-fsl-tools-testapps.bbappend \
    meta-imx/meta-imx-sdk/recipes-fsl/fsl-rc-local/fsl-rc-local.bbappend \
    meta-imx/meta-imx-sdk/recipes-fsl/images/fsl-image-machine-test.bbappend \
    meta-imx/meta-imx-sdk/recipes-fsl/images/fsl-image-multimedia.bbappend \
    meta-imx/meta-imx-sdk/recipes-fsl/packagegroup/packagegroup-fsl-gstreamer1.0.bbappend \
    meta-imx/meta-imx-sdk/recipes-fsl/packagegroup/packagegroup-fsl-tools-benchmark.bbappend \
    meta-imx/meta-imx-sdk/recipes-fsl/packagegroup/packagegroup-fsl-tools-testapps.bbappend \
    meta-imx/meta-imx-sdk/recipes-graphics/devil/devil_%.bbappend \
"

# fix search path
FILESEXTRAPATHS:prepend:pn-imx-boot-phytec := "${LAYERDIR_freescale-layer}/recipes-bsp/imx-mkimage/files:"
FILESEXTRAPATHS:prepend:pn-optee-client := "${LAYERDIR_arm}/recipes-security/optee/optee-client:"

# configure hardware watchdog
# the maximum watchdog deadline depends on the hardware capabilities
SYSTEMD_RuntimeWatchdogSec  = "60"
SYSTEMD_RebootWatchdogSec   = "60"

# this machine uses uboot and pstore feature
MACHINEOVERRIDES:prepend = "omnect_uboot:omnect_pstore:"
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
MACHINE_FEATURES:append = " \
    pstore \
"

OMNECT_BOOTLOADER_RECIPE_PATH = "${LAYERDIR_phytec}/recipes-bsp/u-boot/u-boot-phytec-imx_2024.04-2.2.0-phy11.bb"

# force bootloader version checksum to be old, when sure it's 100% binary compatible
# OMNECT_BOOTLOADER_CHECKSUM_COMPATIBLE:pn-bootloader-versioned = "<newchecksum> <oldchecksum>"
# e.g.:
# OMNECT_BOOTLOADER_CHECKSUM_COMPATIBLE:pn-bootloader-versioned = "2cf3dd5f692d9ed563f06ecf80d0cb566ddc165fa01a37b4eba663dc7b7b9087 ebe0e595a3efb112b7495a14f9562d89d00041390f26a9ad4985435687bf2311"
#
# OMNECT_BOOTLOADER_CHECKSUM_EXPTECTED:pn-bootloader-versioned - build will fail, if the
# computed checksum is different to this; set to <oldchecksum> when
# OMNECT_BOOTLOADER_CHECKSUM_COMPATIBLE:pn-bootloader-versioned is set
OMNECT_BOOTLOADER_CHECKSUM_EXPECTED:pn-bootloader-versioned = "804a1310c7a89dbd91e72ad2ebfedd6ede4656f14c902f03659784164ab4a1e5"
