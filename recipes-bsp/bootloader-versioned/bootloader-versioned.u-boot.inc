DEPENDS = "${OMNECT_BOOTLOADER_EMBEDDED_VERSION_BBTARGET}"

SRC_URI = "file://omnect_get_bootloader_version.sh.template"

OMNECT_BOOTLOADER_EMBEDDED_VERSION_IMAGEOFFSET ?= ""
OMNECT_BOOTLOADER_EMBEDDED_VERSION_IMAGESIZE ?= ""
OMNECT_BOOTLOADER_EMBEDDED_VERSION_LOCATION ?= ""
OMNECT_BOOTLOADER_EMBEDDED_VERSION_IMAGESIZE ?= ""
OMNECT_BOOTLOADER_EMBEDDED_VERSION_UUUTAG ?= ""

# we do not include u-boot upstream recipe, because
# updates in openembedded_core should be handled by `PV` increase
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/recipes-bsp/u-boot/u-boot_%.bbappend"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/recipes-bsp/u-boot/u-boot-scr.bb"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/recipes-bsp/u-boot/u-boot/*"

# since bootloader version gets embedded in bootloader file also
# settings thereof need to be fed into checksumming
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/classes/omnect_uboot_embedded_version.bbclass"

OMNECT_BOOTLOADER_CHECKSUM_FILES_GLOB_IGNORE = "${LAYERDIR_omnect}/recipes-bsp/u-boot/u-boot/.gitignore"
# don't include files which are generated on build:
OMNECT_BOOTLOADER_CHECKSUM_FILES_GLOB_IGNORE += "${LAYERDIR_omnect}/recipes-bsp/u-boot/u-boot/redundant-env-fragment.cfg"

inherit omnect_bootloader_versioning omnect_uboot_embedded_version

do_compile() {
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
