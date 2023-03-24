FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://add-reset-info.patch \
    file://enable-reset-info-cmd-fragment.cfg \
    file://omnect_env.patch \
    file://rpi-always-set-fdt_addr-with-firmware-provided-FDT-address.patch \
    file://omnect_env_rpi.h \
"

do_configure:prepend() {
    cp -f ${WORKDIR}/omnect_env_rpi.h ${S}/include/configs/omnect_env_machine.h
}
