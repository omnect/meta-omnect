FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# for usage in intramfs only

LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"

SRC_URI:omnect_grub = "file://bootloader_env_grub.sh"
SRC_URI:omnect_uboot = "file://bootloader_env_u-boot.sh"

RDEPENDS:${PN} = "bash"
RDEPENDS:${PN}:append:omnect_grub = " grub-editenv"
RDEPENDS:${PN}:append:omnect_uboot = " libubootenv-bin"

do_install:omnect_grub() {
	install -m 0700 -D ${WORKDIR}/bootloader_env_grub.sh ${D}${sbindir}/bootloader_env.sh
}

do_install:omnect_uboot() {
	install -m 0700 -D ${WORKDIR}/bootloader_env_u-boot.sh ${D}${sbindir}/bootloader_env.sh
}
