FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM="\
  file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
  file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"

RDEPENDS:${PN} += "bash"
DEPENDS = "${OMNECT_BOOTLOADER_EMBEDDED_VERSION_BBTARGET}"

SRC_URI = "file://omnect_get_bootloader_version.sh.template"

OMNECT_BOOTLOADER_EMBEDDED_VERSION_IMAGEOFFSET ?= ""
OMNECT_BOOTLOADER_EMBEDDED_VERSION_IMAGESIZE ?= ""
OMNECT_BOOTLOADER_EMBEDDED_VERSION_LOCATION ?= ""
OMNECT_BOOTLOADER_EMBEDDED_VERSION_IMAGESIZE ?= ""

inherit deploy omnect_uboot_embedded_version

# relying on SSTATE cache showed that re-building of verisioned bootlaoder
# artefact didn't work reliably, often an old version was unexpectedly used,
# even though above a dependency to u-boot-karo is defined through variable
# OMNECT_BOOTLOADER_EMBEDDED_VERSION_BBTARGET.
# so, switch off SSTATE for this recipe in the hope that this will cause
# proper rebuilding.
SKIP_SSTATE_CREATION = "1"

do_compile:append() {
    cp "${WORKDIR}/omnect_get_bootloader_version.sh.template" "${WORKDIR}/omnect_get_bootloader_version.sh"
    sed -i -e 's,@@OMNECT_BOOTLOADER_EMBEDDED_VERSION_MAGIC@@,${OMNECT_BOOTLOADER_EMBEDDED_VERSION_MAGIC},g' \
           -e 's,@@OMNECT_BOOTLOADER_EMBEDDED_VERSION_PARAMSIZE@@,${OMNECT_BOOTLOADER_EMBEDDED_VERSION_PARAMSIZE},g' \
           -e 's,@@OMNECT_BOOTLOADER_EMBEDDED_VERSION_IMAGEOFFSET@@,${OMNECT_BOOTLOADER_EMBEDDED_VERSION_IMAGEOFFSET},g' \
           -e 's,@@OMNECT_BOOTLOADER_EMBEDDED_VERSION_IMAGESIZE@@,${OMNECT_BOOTLOADER_EMBEDDED_VERSION_IMAGESIZE},g' \
           -e 's,@@OMNECT_BOOTLOADER_EMBEDDED_VERSION_TYPE@@,${OMNECT_BOOTLOADER_EMBEDDED_VERSION_TYPE},g' \
           -e 's,@@OMNECT_BOOTLOADER_EMBEDDED_VERSION_LOCATION@@,${OMNECT_BOOTLOADER_EMBEDDED_VERSION_LOCATION},g' \
        "${WORKDIR}/omnect_get_bootloader_version.sh"
}

do_install() {
    install -m 0755 -D ${WORKDIR}/omnect_get_bootloader_version.sh ${D}/usr/bin/omnect_get_bootloader_version.sh
}

FILES:${PN} = "/usr/bin/omnect_get_bootloader_version.sh"
