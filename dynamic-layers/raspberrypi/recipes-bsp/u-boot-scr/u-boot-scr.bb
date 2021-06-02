FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

#TODO
#LICENSE = "MIT | Apache-2.0"
LICENSE = "CLOSED"

SRC_URI = "file://boot.cmd.in"

PROVIDES = "u-boot-default-script"
DEPENDS = "u-boot-mkimage-native"
COMPATIBLE = "rpi"

inherit deploy nopackages

do_compile() {
    sed -e 's#@@ROOT_DEV_P@@#${ROOT_DEV_P}#' \
        -e 's/@@KERNEL_IMAGETYPE@@/${KERNEL_IMAGETYPE}/' \
        -e 's/@@KERNEL_BOOTCMD@@/${KERNEL_BOOTCMD}/' \
        "${WORKDIR}/boot.cmd.in" > "${WORKDIR}/boot.cmd"

    mkimage -A ${UBOOT_ARCH} -T script -C none -n "Boot script" -d "${WORKDIR}/boot.cmd" boot.scr
}

do_deploy() {
    install -m 0644 -D boot.scr ${DEPLOYDIR}
}

addtask do_deploy after do_compile before do_build

INHIBIT_DEFAULT_DEPS = "1"
