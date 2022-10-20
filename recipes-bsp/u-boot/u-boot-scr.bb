FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM="\
  file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
  file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"
PROVIDES = "u-boot-default-script"
DEPENDS = "u-boot-mkimage-native"

ICS_DM_BOOT_SCR_NAME = "boot.scr"
ICS_DM_FDT_LOAD_NAME = "fdt-load.scr"
inherit deploy nopackages u-boot-scr
