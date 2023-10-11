omnect_uboot_configure_env() {
    # configure omnect u-boot env
    cp -f ${WORKDIR}/omnect_env.h ${S}/include/configs/
    if [ -n "${APPEND}" ]; then
        sed -i -e "s|^#define OMNECT_ENV_BOOTARGS$|#define OMNECT_ENV_BOOTARGS \"omnect-bootargs=${APPEND}\\\0\"|g" ${S}/include/configs/omnect_env.h
    fi
    if [ "${OMNECT_RELEASE_IMAGE}" = "1" ]; then
        sed -i -e "s|^//#define OMNECT_RELEASE_IMAGE$|#define OMNECT_RELEASE_IMAGE|g" ${S}/include/configs/omnect_env.h
    fi
    if [ -n "${OMNECT_UBOOT_WRITEABLE_ENV_FLAGS}" ]; then
        sed -i -e "s|^#define OMNECT_REQUIRED_WRITEABLE_ENV_FLAGS_EXTRA$|#define OMNECT_REQUIRED_WRITEABLE_ENV_FLAGS_EXTRA \"${OMNECT_UBOOT_WRITEABLE_ENV_FLAGS}\\\0\"|g" ${S}/include/configs/omnect_env.h
    fi
}
