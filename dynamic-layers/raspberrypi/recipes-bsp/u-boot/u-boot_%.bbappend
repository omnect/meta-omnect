FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://add-reset-info.patch \
    file://enable-reset-info-cmd-fragment.cfg \
    file://omnect_env.patch \
    file://rpi-always-set-fdt_addr-with-firmware-provided-FDT-address.patch \
    file://omnect_env_rpi.h \
"

# Appends a string to the name of the local version of the U-Boot image; e.g. "-1"; if you like to update the bootloader via
# swupdate and iot-hub-device-update, the local version must be increased;
UBOOT_LOCALVERSION = "-1"
PKGV = "${PV}${UBOOT_LOCALVERSION}"

do_configure:prepend() {
    cp -f ${WORKDIR}/omnect_env_rpi.h ${S}/include/configs/omnect_env_machine.h
}

do_deploy:append() {
  echo "${PKGV}" > ${DEPLOY_DIR_IMAGE}/bootloader_version
}
