inherit omnect_fw_env_config
DEPENDS += "u-boot-mkenvimage-native"

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

do_configure:prepend() {
    omnect_uboot_configure_env
}

do_compile:append() {
    size=$(omnect_conv_size_param "${OMNECT_PART_SIZE_UBOOT_ENV}"    "u-boot env. size")
    mkenvimage="mkenvimage"
    if [ "${OMNECT_PART_REDUNDANT_UBOOT_ENV}" = "1" ]; then
        mkenvimage="mkenvimage -r"
    fi
    if [ -n "${UBOOT_CONFIG}" ]; then
        # this is based on the handling in openembedded-core/meta/recipes-bsp/u-boot/u-boot.inc
        for config in ${UBOOT_MACHINE}; do
            initial_env="${B}/${config}/u-boot-initial-env"
            # so far i don't see that `UBOOT_MACHINE` is ever set to multiple configs
            break;
        done
    else
        initial_env="${B}/u-boot-initial-env"
    fi
    ${mkenvimage} -s ${size} -o ${WORKDIR}/uboot-env.bin ${initial_env}
}

do_deploy:append() {
    install -m 0644 -D ${WORKDIR}/uboot-env.bin ${DEPLOYDIR}/
}
