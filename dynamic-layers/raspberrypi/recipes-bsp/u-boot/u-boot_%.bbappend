FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:${LAYERDIR_raspberrypi}/recipes-bsp/u-boot/files:"

SRC_URI += "\
    file://add-reset-info.patch \
    file://omnect_env_rpi.patch \
    file://cap-bootmapsz-cma.patch \
    file://enable-reset-info-cmd-fragment.cfg \
    file://redundant-env.cfg \
    file://omnect_env_rpi.h \
"

do_configure:prepend() {
    cp -f ${UNPACKDIR}/omnect_env_rpi.h ${S}/include/configs/omnect_env_machine.h
}
