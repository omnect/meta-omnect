FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:${LAYERDIR_raspberrypi}/recipes-bsp/u-boot/files:"

# enable-reset-info-cmd-fragment.cfg keeps CONFIG_DISPLAY_CPUINFO *off*: the
# 2026.01 rpi defconfig force-selects CONFIG_CPU, so enabling DISPLAY_CPUINFO
# would pull board_f.c's DM print_cpuinfo() into board_init_f(), which aborts
# with -ENODEV because rpi has no cpu-uclass device (a fragment can't undo the
# CONFIG_CPU select). The reset cause is exposed via the rstinfo command instead.
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
