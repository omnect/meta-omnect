FILESEXTRAPATHS:prepend := "${THISDIR}/omnect-os:"

DESCRIPTION = "omnect-os swupdate image"

LICENSE = "MIT | Apache-2.0"

LIC_FILES_CHKSUM = "\
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"

SRC_URI = "file://sw-description"

COMPATIBLE_MACHINE = "rpi|phytec-imx8mm|omnect_grub"

# needed to get access to PKGV
DEPENDS += "virtual/bootloader"

addtask do_bootloader_package before do_swuimage

do_bootloader_package_extra_depends = ""
do_bootloader_package_extra_depends:omnect_uboot = "u-boot-scr:do_deploy"
do_bootloader_package[depends] += "virtual/bootloader:do_deploy virtual/kernel:do_deploy ${do_bootloader_package_extra_depends}"

do_bootloader_package() {
    echo "unexpected usage of default do_bootloader_package function"
    exit 1
}

do_bootloader_package:rpi() {
    BOOT_FILES="${IMAGE_BOOT_FILES}"
    mkdir -p ${DEPLOY_DIR_IMAGE}/boot-partition/overlays
    for entry in ${BOOT_FILES} ; do
        # Split entry at optional ';' to enable file renaming for the destination
        DEPLOY_FILE=$(IFS=";"; set -- $entry; echo $1)
        DEST_FILENAME=$(IFS=";"; set -- $entry; echo $2)
        [ -f "${DEPLOY_DIR_IMAGE}/$entry" ] && DEST_FILENAME=${DEST_FILENAME:-${DEPLOY_FILE}}
        cp ${DEPLOY_DIR_IMAGE}/${DEPLOY_FILE} ${DEPLOY_DIR_IMAGE}/boot-partition/${DEST_FILENAME}
    done
    # Notice: config.txt should not be overwritten via swupdate, content is costumer specific!
    mv ${DEPLOY_DIR_IMAGE}/boot-partition/config.txt ${DEPLOY_DIR_IMAGE}/boot-partition/config.txt.omnect
    tar -czvf boot-partition-update.tar.gz -C ${DEPLOY_DIR_IMAGE}/boot-partition .
}

do_bootloader_package:phytec-imx8mm() {
    tar -czvf boot-partition-update.tar.gz -C ${DEPLOY_DIR_IMAGE} boot.scr fdt-load.scr
}

do_bootloader_package:omnect_grub() {
    mkdir -p ${WORKDIR}/EFI/BOOT
    cp ${DEPLOY_DIR_IMAGE}/grub-efi-bootx64.efi ${WORKDIR}/EFI/BOOT/bootx64.efi
    cp ${DEPLOY_DIR_IMAGE}/bootloader_version   ${WORKDIR}/EFI/BOOT/bootloader_version
    sed "s#@@ROOT_DEVICE@@#/dev/nvme0n1p#g" ${LAYERDIR_omnect}/recipes-omnect/grub-cfg/grub-cfg/grub.cfg.in > ${WORKDIR}/EFI/BOOT/grub.cfg
    cd ${WORKDIR}
    tar cfz boot-partition-update.tar.gz EFI/BOOT/*
}

do_bootloader_package:append() {
    install -m 0644 -D boot-partition-update.tar.gz ${DEPLOY_DIR_IMAGE}
}

inherit swupdate

# images to build before building swupdate image
IMAGE_DEPENDS = "omnect-os-image"

IMAGE_NAME = "${DISTRO_NAME}_${DISTRO_VERSION}_${MACHINE}"

# images and files that will be included in the .swu image
SWUPDATE_IMAGES = "omnect-os ${@bb.utils.contains('MACHINE', 'phygate-tauri-l-imx8mm-2', 'imx-boot', '', d)} boot-partition-update"

SWUPDATE_IMAGES_FSTYPES[omnect-os] = ".ext4.gz"
SWUPDATE_IMAGES_FSTYPES[boot-partition-update] = ".tar.gz"

#sign image
SWUPDATE_SIGNING = "RSA"
