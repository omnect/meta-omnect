FILESEXTRAPATHS_prepend := "${THISDIR}/ics-dm-os-initramfs:"

LICENSE = "MIT | Apache-2.0"

LIC_FILES_CHKSUM = "\
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"
SRC_URI = "\
    file://rootblk-dev \
    file://common-sh \
    file://factory-reset \
    file://resize-data \
    file://fs-mount \
"

# factory reset: (optional) custom wipe script
FACTORY_RESET_TARGET_WIPE_DIR = "/opt/factory_reset"
FACTORY_RESET_TARGET_WIPE_SCRIPT = "custom-wipe"

FILESEXTRAPATHS_prepend := "${@'${FACTORY_RESET_CUSTOM_WIPE_DIR}:' if d.getVar('FACTORY_RESET_CUSTOM_WIPE_DIR', True) else ''}"
SRC_URI_append = "${@' file://${FACTORY_RESET_TARGET_WIPE_SCRIPT}' if d.getVar('FACTORY_RESET_CUSTOM_WIPE_DIR', True) else ''}"

do_install() {
    install -m 0755 -D ${WORKDIR}/rootblk-dev      ${D}/init.d/10-rootblk_dev
    install -m 0755 -D ${WORKDIR}/common-sh        ${D}/init.d/86-common_sh
    install -m 0755 -D ${WORKDIR}/factory-reset    ${D}/init.d/87-factory_reset
    install -m 0755 -D ${WORKDIR}/resize-data      ${D}/init.d/88-resize_data
    install -m 0755 -D ${WORKDIR}/fs-mount         ${D}/init.d/89-fs_mount
    if [ -n "${FACTORY_RESET_CUSTOM_WIPE_DIR}" ]; then
        install -d ${D}${FACTORY_RESET_TARGET_WIPE_DIR}
        install -m 0755 -D ${FACTORY_RESET_CUSTOM_WIPE_DIR}/${FACTORY_RESET_TARGET_WIPE_SCRIPT} ${D}${FACTORY_RESET_TARGET_WIPE_DIR}
    fi
}

FILES_${PN} = "\
    /init.d/10-rootblk_dev \
    /init.d/86-common_sh \
    /init.d/87-factory_reset \
    /init.d/88-resize_data \
    /init.d/89-fs_mount \
"

FILES_${PN} += "${@'${FACTORY_RESET_TARGET_WIPE_DIR}/${FACTORY_RESET_TARGET_WIPE_SCRIPT}' if d.getVar('FACTORY_RESET_CUSTOM_WIPE_DIR', True) else ''}"
