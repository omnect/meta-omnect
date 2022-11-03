FILESEXTRAPATHS:prepend := "${THISDIR}/omnect-os:"

DESCRIPTION = "omnect-os swupdate image"

LICENSE = "MIT | Apache-2.0"

LIC_FILES_CHKSUM = "\
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"

SRC_URI = "file://sw-description"

inherit swupdate

# images to build before building swupdate image
IMAGE_DEPENDS = "omnect-os-image virtual/kernel"

IMAGE_NAME = "${DISTRO_NAME}_${DISTRO_VERSION}_${MACHINE}"

# images and files that will be included in the .swu image
SWUPDATE_IMAGES = "omnect-os"

SWUPDATE_IMAGES_FSTYPES[omnect-os] = ".ext4.gz"

#sign image
SWUPDATE_SIGNING = "RSA"
