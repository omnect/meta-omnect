FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://add-reset-info.patch \
    file://enable-reset-info-cmd-fragment.cfg \
    file://omnect_env.patch \
    file://rpi-always-set-fdt_addr-with-firmware-provided-FDT-address.patch \
    file://omnect_env_rpi.h \
"

# Appends a string to the name of the local version of the U-Boot image; e.g. "-1"; if you like to update the bootloader via
# swupdate and iot-hub-device-update, the local version must be increased;
UBOOT_LOCALVERSION = "-1"
PKGV = "${PV}${UBOOT_LOCALVERSION}"

do_configure:prepend() {
    cp -f ${WORKDIR}/omnect_env_rpi.h ${S}/include/configs/omnect_env_machine.h
}


do_install:append() {
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
