FILESEXTRAPATHS:prepend := "${THISDIR}/omnect-os:"

DESCRIPTION = "omnect-os swupdate image"

LICENSE = "MIT | Apache-2.0"

LIC_FILES_CHKSUM = "\
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"

SRC_URI = "file://sw-description"

python () {
    if d.getVar('MACHINE') == 'raspberrypi4-64':
        bb.build.addtask('do_bootloader_rpi', 'do_swuimage', 'do_unpack do_prepare_recipe_sysroot', d)
    elif d.getVar('MACHINE') == 'phygate-tauri-l-imx8mm-2':
        bb.build.addtask('do_bootloader_tauri', 'do_swuimage', 'do_unpack do_prepare_recipe_sysroot', d)
    else:
        raise bb.parse.SkipRecipe("MACHINE type unknown for omnect-os-update-image.")
}

do_bootloader_rpi() {
    BOOT_FILES="${IMAGE_BOOT_FILES}"
    mkdir -p ${DEPLOY_DIR_IMAGE}/boot-partition/overlays
    for entry in ${BOOT_FILES} ; do
        # Split entry at optional ';' to enable file renaming for the destination
        DEPLOY_FILE=$(IFS=";"; set -- $entry; echo $1)
        DEST_FILENAME=$(IFS=";"; set -- $entry; echo $2)
        [ -f "${DEPLOY_DIR_IMAGE}/$entry" ] && DEST_FILENAME=${DEST_FILENAME:-${DEPLOY_FILE}}
        cp ${DEPLOY_DIR_IMAGE}/${DEPLOY_FILE} ${DEPLOY_DIR_IMAGE}/boot-partition/${DEST_FILENAME}
    done

    tar -czvf boot-partition-update.tar.gz -C ${DEPLOY_DIR_IMAGE}/boot-partition .
    install -m 0644 -D boot-partition-update.tar.gz ${DEPLOY_DIR_IMAGE}
}

do_bootloader_tauri() {
    tar -czvf boot-partition-update.tar.gz -C ${DEPLOY_DIR_IMAGE} boot.scr fdt-load.scr
    install -m 0644 -D boot-partition-update.tar.gz ${DEPLOY_DIR_IMAGE}
}

inherit swupdate

# images to build before building swupdate image
IMAGE_DEPENDS = "omnect-os-image virtual/kernel"

IMAGE_NAME = "${DISTRO_NAME}_${DISTRO_VERSION}_${MACHINE}"

# images and files that will be included in the .swu image
SWUPDATE_IMAGES = "omnect-os ${@bb.utils.contains('MACHINE', 'phygate-tauri-l-imx8mm-2', 'imx-boot', '', d)} boot-partition-update"

SWUPDATE_IMAGES_FSTYPES[omnect-os] = ".ext4.gz"
SWUPDATE_IMAGES_FSTYPES[boot-partition-update] = ".tar.gz"

#sign image
SWUPDATE_SIGNING = "RSA"
