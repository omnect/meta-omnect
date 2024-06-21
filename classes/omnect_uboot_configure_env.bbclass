omnect_uboot_configure_env() {
    # configure omnect u-boot env
    cp -f ${WORKDIR}/omnect_env.h ${S}/include/configs/
    cp -f ${WORKDIR}/omnect_env.env ${S}/include/env/

    # set omnect-bootargs
    local omnect_env_bootargs=""
    if [ -n "${APPEND}" ]; then
        omnect_env_bootargs="omnect-bootargs=${APPEND}"
    fi
    sed -i -e "s|^@@OMNECT_ENV_BOOTARGS@@$|${omnect_env_bootargs}|g" ${S}/include/env/omnect_env.env

    # set release image
    if [ "${OMNECT_RELEASE_IMAGE}" = "1" ]; then
        sed -i -e "s|^//#define OMNECT_RELEASE_IMAGE$|#define OMNECT_RELEASE_IMAGE|g" ${S}/include/env/omnect_env.env

    fi

    # concatenate extra writable env flags
    if [ -n "${OMNECT_UBOOT_WRITEABLE_ENV_FLAGS}" ]; then
        sed -i -e "s|^#define OMNECT_REQUIRED_WRITEABLE_ENV_FLAGS_EXTRA$|#define OMNECT_REQUIRED_WRITEABLE_ENV_FLAGS_EXTRA \"${OMNECT_UBOOT_WRITEABLE_ENV_FLAGS}\"|g" ${S}/include/configs/omnect_env.h
    fi
}
