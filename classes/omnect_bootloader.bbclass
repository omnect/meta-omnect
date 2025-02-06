do_configure:prepend () {
    if [ "${FILE}" != ${OMNECT_BOOTLOADER_RECIPE_PATH} ]; then
        bbfatal "OMNECT_BOOTLOADER_RECIPE_PATH:${OMNECT_BOOTLOADER_RECIPE_PATH} doesnt match FILE:${FILE}."
    fi
}

do_deploy:append () {
    echo -n "${PV}" > ${DEPLOYDIR}/omnect_bootloader_pv
}
