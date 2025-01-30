# we do not include grub-efi, resp grub upstream recipes, because
# updates in openembedded_core should be handled by `PV` increase
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/recipes-bsp/grub/grub-efi_%.bbappend"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/recipes-omnect/grub-cfg/grub-cfg.bb"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/recipes-omnect/grub-cfg/grub-cfg/grub.cfg.in"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/recipes-omnect/grub-env/grub-env.bb"
OMNECT_BOOTLOADER_CHECKSUM_FILES += "${LAYERDIR_omnect}/files/grubenv"

inherit deploy omnect_bootloader_versioning

do_deploy() {
    echo "$(cat ${DEPLOY_DIR_IMAGE}/omnect_bootloader_pv)-$(cat ${DEPLOY_DIR_IMAGE}/omnect_bootloader_checksum)" > ${DEPLOYDIR}/omnect_bootloader_version
}
do_deploy[depends]  += "virtual/bootloader:do_deploy "

# Note: version is written to boot partition by kas/patches/oe_bootimg_efi_wic.patch
