do_configure:prepend () {
    if [ "${FILE}" != ${OMNECT_BOOTLOADER_RECIPE_PATH} ]; then
        bberror "OMNECT_BOOTLOADER_RECIPE_PATH:${OMNECT_BOOTLOADER_RECIPE_PATH} doesnt match FILE:${FILE}."
    fi
}