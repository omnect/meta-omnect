FILESEXTRAPATHS:prepend := "${THISDIR}/u-boot:${LAYERDIR_omnect}/recipes-bsp/u-boot/u-boot:"

SRC_URI += "\
    file://enable_boot_script.patch\
    file://add-reset-info.patch\
    file://omnect_env.patch\
    file://silent_console_early.patch\
    file://enable_generic_console_fs_cmds.cfg\
    file://enable-reset-info-cmd-fragment.cfg\
    file://enable-pxe-cmd.cfg\
    file://silent_console.cfg\
    file://omnect_env.h\
"

do_configure:prepend() {
    # configure omnect u-boot env
    if [ -n "${APPEND}" ]; then
      sed -i -e "s|^#define OMNECT_ENV_SETTINGS \(.*\)$|#define OMNECT_ENV_SETTINGS \\\ \n\"extra-bootargs=${APPEND}\\\0\" \\\|g" ${WORKDIR}/omnect_env.h
    fi

    if [ "${OMNECT_RELEASE_IMAGE}" = "1" ]; then
        sed -i -e "s|^#define OMNECT_ENV_SETTINGS \(.*\)$|#define OMNECT_ENV_SETTINGS \\\ \n\"bootdelay=-2\\\0\" \\\ \n\"silent=1\\\0\" \\\|g" ${WORKDIR}/omnect_env.h
    fi

    mv ${WORKDIR}/omnect_env.h ${S}/include/configs/
}
