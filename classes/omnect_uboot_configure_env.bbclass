omnect_uboot_configure_env() {
    # configure omnect u-boot env
    cp -f ${WORKDIR}/omnect_env.h ${S}/include/configs/

    # set omnect_u-boot_version
    OMNECT_BOOTLOADER_VERSION=$(cat ${WORKDIR}/omnect_bootloader_version)
    sed -i -e "s|^#define OMNECT_ENV_BOOTLOADER_VERSION$|#define OMNECT_ENV_BOOTLOADER_VERSION \"omnect_u-boot_version=${OMNECT_BOOTLOADER_VERSION}\\\0\"|g" ${S}/include/configs/omnect_env.h

    # set omnect-bootargs
    if [ -n "${APPEND}" ]; then
        sed -i -e "s|^#define OMNECT_ENV_BOOTARGS$|#define OMNECT_ENV_BOOTARGS \"omnect-bootargs=${APPEND}\\\0\"|g" ${S}/include/configs/omnect_env.h
    fi

    # set release image
    if [ "${OMNECT_RELEASE_IMAGE}" = "1" ]; then
        sed -i -e "s|^//#define OMNECT_RELEASE_IMAGE$|#define OMNECT_RELEASE_IMAGE|g" ${S}/include/configs/omnect_env.h
    fi

    # concatenate extra writable env flags
    if [ -n "${OMNECT_UBOOT_WRITEABLE_ENV_FLAGS}" ]; then
        sed -i -e "s|^#define OMNECT_REQUIRED_WRITEABLE_ENV_FLAGS_EXTRA$|#define OMNECT_REQUIRED_WRITEABLE_ENV_FLAGS_EXTRA \"${OMNECT_UBOOT_WRITEABLE_ENV_FLAGS}\"|g" ${S}/include/configs/omnect_env.h
    fi
}
