FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:${LAYERDIR_raspberrypi}/recipes-bsp/u-boot/files:"

SRC_URI += "\
    file://0001-rpi-always-set-fdt_addr-with-firmware-provided-FDT-address.patch \
    file://add-reset-info.patch \
    file://omnect_env_rpi.patch \
    file://enable-reset-info-cmd-fragment.cfg \
    file://redundant-env.cfg \
    file://omnect_env_rpi.h \
"

do_configure:prepend() {
    cp -f ${WORKDIR}/omnect_env_rpi.h ${S}/include/configs/omnect_env_machine.h
}
