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
    file://rootfs-mount \
"

do_install() {
    install -m 0755 -D ${WORKDIR}/rootblk-dev      ${D}/init.d/10-rootblk_dev
    install -m 0755 -D ${WORKDIR}/common-sh        ${D}/init.d/86-common_sh
    install -m 0755 -D ${WORKDIR}/factory-reset    ${D}/init.d/87-factory_reset
    install -m 0755 -D ${WORKDIR}/resize-data      ${D}/init.d/88-resize_data
    install -m 0755 -D ${WORKDIR}/rootfs-mount     ${D}/init.d/89-rootfs
}

FILES_${PN} = "\
    /init.d/10-rootblk_dev \
    /init.d/86-common_sh \
    /init.d/87-factory_reset \
    /init.d/88-resize_data \
    /init.d/89-rootfs \
"
