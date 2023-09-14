FILESEXTRAPATHS:prepend := "${THISDIR}/omnect-os-initramfs:"

LICENSE = "MIT | Apache-2.0"

LIC_FILES_CHKSUM = "\
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"
SRC_URI = "\
    file://rootblk-dev \
    file://common-sh \
    file://factory-reset \
    file://flash-mode-1 \
    file://fs-mount \
    file://omnect-device-service-setup \
"
SRC_URI:append = "${@bb.utils.contains('DISTRO_FEATURES', 'flash-mode-2', ' file://flash-mode-2', '', d)}"
SRC_URI:append = "${@bb.utils.contains('DISTRO_FEATURES', 'resize-data', ' file://resize-data', '', d)}"
SRC_URI:append = "${@bb.utils.contains('DISTRO_FEATURES', 'persistent-var-log', ' file://persistent-var-log', '', d)}"
SRC_URI:append:mx8mm-nxp-bsp = " file://imx-sdma"
SRC_URI:append:omnect_grub = " file://grub-sh"
SRC_URI:append:omnect_uboot = " file://uboot-sh"

RDEPENDS:${PN} = "bash"

do_install() {
    install -m 0755 -D ${WORKDIR}/common-sh              ${D}/init.d/05-common_sh
    install -m 0755 -D ${WORKDIR}/rootblk-dev            ${D}/init.d/10-rootblk_dev

    install -m 0755 -D ${WORKDIR}/factory-reset          ${D}/init.d/86-factory_reset

    install -m 0755 -D ${WORKDIR}/flash-mode-1           ${D}/init.d/87-flash_mode_1
    # set variables templates
    sed -i -e 's|^\(OMNECT_FLASH_MODE_UBOOT_ENV1_START\)="UNDEFINED"|\1="${OMNECT_PART_OFFSET_UBOOT_ENV1}"|' \
           -e 's|^\(OMNECT_FLASH_MODE_UBOOT_ENV2_START\)="UNDEFINED"|\1="${OMNECT_PART_OFFSET_UBOOT_ENV2}"|' \
           -e 's|^\(OMNECT_FLASH_MODE_UBOOT_ENV_SIZE\)="UNDEFINED"|\1="${OMNECT_PART_SIZE_UBOOT_ENV}"|' \
           -e 's|^\(OMNECT_FLASH_MODE_DATA_SIZE\)="UNDEFINED"|\1="${OMNECT_PART_SIZE_DATA}"|' \
              ${D}/init.d/87-flash_mode_1
    if [ -n "${BOOTLOADER_SEEK}" ]; then
        sed -i -e 's|^\(OMNECT_FLASH_MODE_BOOTLOADER_START\)="UNDEFINED"|\1="${BOOTLOADER_SEEK}"|' ${D}/init.d/87-flash_mode_1
    fi

    if ${@bb.utils.contains('DISTRO_FEATURES', 'flash-mode-2', 'true', 'false', d)}; then
        install -m 0755 -D ${WORKDIR}/flash-mode-2                          ${D}/init.d/87-flash_mode_2
        sed -i "s/@@OMNECT_PART_SIZE_BOOT@@/${OMNECT_PART_SIZE_BOOT}/g"     ${D}/init.d/87-flash_mode_2
    fi
    if ${@bb.utils.contains('DISTRO_FEATURES', 'resize-data', 'true', 'false', d)}; then
        install -m 0755 -D ${WORKDIR}/resize-data        ${D}/init.d/88-resize_data
    fi
    install -m 0755 -D ${WORKDIR}/fs-mount               ${D}/init.d/89-fs_mount
    if ${@bb.utils.contains('DISTRO_FEATURES', 'persistent-var-log', 'true', 'false', d)}; then
        install -m 0755 -D ${WORKDIR}/persistent-var-log ${D}/init.d/90-persistent_var_log
    fi
    install -m 0755 -D ${WORKDIR}/omnect-device-service-setup    ${D}/init.d/95-omnect_device_service_setup
}

do_install:append:mx8mm-nxp-bsp () {
    install -m 0755 -D ${WORKDIR}/imx-sdma               ${D}/init.d/90-imx_sdma
}

do_install:append:omnect_grub () {
    install -m 0755 -D ${WORKDIR}/grub-sh            ${D}/init.d/11-bootloader_sh
}

do_install:append:omnect_uboot () {
    install -m 0755 -D ${WORKDIR}/uboot-sh           ${D}/init.d/11-bootloader_sh
}

FILES:${PN} = "\
    /init.d/05-common_sh \
    /init.d/10-rootblk_dev \
    /init.d/11-bootloader_sh \
    /init.d/86-factory_reset \
    /init.d/87-flash_mode_1 \
    /init.d/89-fs_mount \
    /init.d/95-omnect_device_service_setup \
"
FILES:${PN}:append = "${@bb.utils.contains('DISTRO_FEATURES', 'flash-mode-2', ' /init.d/87-flash_mode_2', '', d)}"
FILES:${PN}:append = "${@bb.utils.contains('DISTRO_FEATURES', 'resize-data', ' /init.d/88-resize_data', '', d)}"
FILES:${PN}:append = "${@bb.utils.contains('DISTRO_FEATURES', 'persistent-var-log', ' /init.d/90-persistent_var_log', '', d)}"
FILES:${PN}:append:mx8mm-nxp-bsp = " /init.d/90-imx_sdma"
