FILESEXTRAPATHS:prepend := "${THISDIR}/u-boot:${LAYERDIR_omnect}/recipes-bsp/u-boot/u-boot:"

SRC_URI += " \
    file://add-reset-info.patch \
    file://omnect_env.patch \
    file://silent_console_early.patch \
    file://enable_generic_console_fs_cmds.cfg \
    file://enable-reset-info-cmd-fragment.cfg \
    file://enable-pxe-cmd.cfg \
    file://lock-env.cfg \
    file://reloc_gd_env.cfg \
    file://silent_console.cfg \
    file://omnect_env.h \
    file://omnect_env_phycore_imx8mm.h \
"

# Appends a string to the name of the local version of the U-Boot image; e.g. "-1"; if you like to update the bootloader via
# swupdate and iot-hub-device-update, the local version must be increased;
#
# Note: `UBOOT_LOCALVERSION` should be also increased on change of variables
#   `APPEND`,
#   `OMNECT_UBOOT_WRITEABLE_ENV_FLAGS`
UBOOT_LOCALVERSION = "-6"
PKGV = "${PV}${UBOOT_LOCALVERSION}"

inherit omnect_uboot_configure_env

do_configure:prepend() {
    omnect_uboot_configure_env
}

do_configure:prepend:mx8mm-nxp-bsp() {
    cp -f ${WORKDIR}/omnect_env_phycore_imx8mm.h ${S}/include/configs/omnect_env_machine.h
}

do_deploy:append() {
  echo "${PKGV}" > ${DEPLOYDIR}/bootloader_version
}
