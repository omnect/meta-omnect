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
UBOOT_LOCALVERSION = "-1"
PKGV = "${PV}${UBOOT_LOCALVERSION}"

do_configure:prepend() {
    # configure omnect u-boot env
    cp -f ${WORKDIR}/omnect_env.h ${S}/include/configs/

    sed -i -e "s|^#define OMNECT_ENV_BOOTLOADER_VERSION$|#define OMNECT_ENV_BOOTLOADER_VERSION \"omnect_u-boot_version=${PKGV}\\\0\"|g" ${S}/include/configs/omnect_env.h

    if [ -n "${APPEND}" ]; then
        sed -i -e "s|^#define OMNECT_ENV_BOOTARGS$|#define OMNECT_ENV_BOOTARGS \"omnect-bootargs=${APPEND}\\\0\"|g" ${S}/include/configs/omnect_env.h
    fi
    if [ "${OMNECT_RELEASE_IMAGE}" = "1" ]; then
        sed -i -e "s|^//#define OMNECT_RELEASE_IMAGE$|#define OMNECT_RELEASE_IMAGE|g" ${S}/include/configs/omnect_env.h
    fi
}

do_configure:prepend:mx8mm-nxp-bsp() {
    cp -f ${WORKDIR}/omnect_env_phycore_imx8mm.h ${S}/include/configs/omnect_env_machine.h
}

do_deploy:append() {
  echo "${PKGV}" > ${DEPLOYDIR}/bootloader_version
}
