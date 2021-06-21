FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"


LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM="\
  file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
  file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"
PROVIDES = "u-boot-default-script"
DEPENDS = "u-boot-mkimage-native"
COMPATIBLE = "rpi"

inherit deploy nopackages u-boot-scr

do_compile() {
    mkimage -A ${UBOOT_ARCH} -T script -C none -n "${DISTRO_NAME} (${DISTRO_VERSION}) u-boot:\n" -d "${WORKDIR}/boot.cmd" boot.scr
}

do_deploy() {
    install -m 0644 -D boot.scr ${DEPLOYDIR}
}

addtask do_deploy after do_compile before do_build

INHIBIT_DEFAULT_DEPS = "1"
