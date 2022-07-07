FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM="\
  file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
  file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"

ICS_DM_BOOT_SCR_NAME = "test-boot.scr"

# 0xC031111 is rpi4 1.1 (https://elinux.org/RPi_HardwareHistory)
ICS_DM_BOOT_SCR_TEST_CMDS:raspberrypi4-64  = 'setenv bootcmd_pxe "dhcp; run fix_rpi4_1_1; if pxe get; then pxe boot; fi"; '
ICS_DM_BOOT_SCR_TEST_CMDS:raspberrypi4-64 .= 'setenv fix_rpi4_1_1 "if test \"0xC03111\" = \"${board_revision}\"; then setenv bootfile /custom/; setenv extra-bootargs sdhci.debug_quirks2=4; saveenv; fi"; '
ICS_DM_BOOT_SCR_TEST_CMDS:raspberrypi4-64 .= 'run fix_rpi4_1_1;rstinfo; if test "${rstinfo}" = "POR"; then echo "Power-on detected; going to run PXE boot..."; run bootcmd_pxe; fi'

ICS_DM_BOOT_SCR_TEST_CMDS      = 'rstinfo; if test "${rstinfo}" = "POR"; then echo "Power-on detected; going to run PXE boot..."; run bootcmd_pxe; fi'
inherit deploy nopackages u-boot-scr
