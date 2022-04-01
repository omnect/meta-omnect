FILESEXTRAPATHS:prepend := "${THISDIR}/ics-dm-os-initramfs:"

LICENSE = "MIT | Apache-2.0"

LIC_FILES_CHKSUM = "\
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"
SRC_URI = "\
    file://rootblk-dev \
    file://common-sh \
    file://factory-reset \
    file://fs-mount \
    file://factory-reset-setup \
"
SRC_URI:append = "${@bb.utils.contains('DISTRO_FEATURES', 'resize-data', ' file://resize-data', '', d)}"
SRC_URI:append = "${@bb.utils.contains('DISTRO_FEATURES', 'persistent-var-log', ' file://persistent-var-log', '', d)}"

do_install() {
    install -m 0755 -D ${WORKDIR}/rootblk-dev            ${D}/init.d/10-rootblk_dev
    install -m 0755 -D ${WORKDIR}/common-sh              ${D}/init.d/85-common_sh
    install -m 0755 -D ${WORKDIR}/factory-reset          ${D}/init.d/86-factory_reset
    if ${@bb.utils.contains('DISTRO_FEATURES', 'resize-data', 'true', 'false', d)}; then
        install -m 0755 -D ${WORKDIR}/resize-data        ${D}/init.d/88-resize_data
    fi
    install -m 0755 -D ${WORKDIR}/fs-mount               ${D}/init.d/89-fs_mount
    if ${@bb.utils.contains('DISTRO_FEATURES', 'persistent-var-log', 'true', 'false', d)}; then
        install -m 0755 -D ${WORKDIR}/persistent-var-log ${D}/init.d/90-persistent_var_log
    fi
    install -m 0755 -D ${WORKDIR}/factory-reset-setup    ${D}/init.d/95-factory_reset_setup
}

FILES:${PN} = "\
    /init.d/10-rootblk_dev \
    /init.d/85-common_sh \
    /init.d/86-factory_reset \
    /init.d/89-fs_mount \
    /init.d/95-factory_reset_setup \
"
FILES:${PN}:append = "${@bb.utils.contains('DISTRO_FEATURES', 'resize-data', ' /init.d/88-resize_data', '', d)}"
FILES:${PN}:append = "${@bb.utils.contains('DISTRO_FEATURES', 'persistent-var-log', ' /init.d/90-persistent_var_log', '', d)}"
