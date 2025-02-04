FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM="\
  file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
  file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"

RDEPENDS:${PN} += "bash"

OMNECT_BOOTLOADER_CHECKSUM_FILES = "${OMNECT_BOOTLOADER_RECIPE_PATH}"

include_recipe = "not set"
include_recipe:omnect_uboot = "bootloader-versioned.u-boot.inc"
include_recipe:omnect_grub = "bootloader-versioned.grub.inc"
require ${include_recipe}

do_compile[vardeps] = "OMNECT_BOOTLOADER_CHECKSUM_EXPECTED"
addtask do_deploy after do_compile before do_build

FILES:${PN} = "/usr/bin/omnect_get_bootloader_version.sh"

INHIBIT_DEFAULT_DEPS = "1"
