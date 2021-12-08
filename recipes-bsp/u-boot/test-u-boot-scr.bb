FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM="\
  file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
  file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"

ICS_DM_BOOT_SCR_NAME = "test-boot.scr"
ICS_DM_BOOT_SCR_TEST_CMDS = 'rstinfo; if test "${rstinfo}" = "POR"; then echo "Power-on detected; going to run PXE boot..."; run bootcmd_pxe; fi'
inherit deploy nopackages u-boot-scr
