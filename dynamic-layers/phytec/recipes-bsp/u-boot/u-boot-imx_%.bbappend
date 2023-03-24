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

do_configure:prepend() {
    # configure omnect u-boot env
    cp -f ${WORKDIR}/omnect_env.h ${S}/include/configs/

    if [ -n "${APPEND}" ]; then
        sed -i -e "s|^#define OMNECT_ENV_EXTRA_BOOTARGS$|#define OMNECT_ENV_EXTRA_BOOTARGS \"extra-bootargs=${APPEND}\\\0\"|g" ${S}/include/configs/omnect_env.h
    fi
    if [ "${OMNECT_RELEASE_IMAGE}" = "1" ]; then
        sed -i -e "s|^//#define OMNECT_RELEASE_IMAGE$|#define OMNECT_RELEASE_IMAGE|g" ${S}/include/configs/omnect_env.h
    fi
}

do_configure:prepend:mx8mm-nxp-bsp() {
    cp -f ${WORKDIR}/omnect_env_phycore_imx8mm.h ${S}/include/configs/omnect_env_machine.h
}
