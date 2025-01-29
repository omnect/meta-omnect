do_configure:prepend () {
    if [ "${FILE}" != ${OMNECT_BOOTLOADER_RECIPE_PATH} ]; then
        bbfatal "OMNECT_BOOTLOADER_RECIPE_PATH:${OMNECT_BOOTLOADER_RECIPE_PATH} doesnt match FILE:${FILE}."
    fi
}

do_deploy:append () {
    echo "${PV}" > ${DEPLOY_DIR_IMAGE}/omnect_bootloader_pv
}