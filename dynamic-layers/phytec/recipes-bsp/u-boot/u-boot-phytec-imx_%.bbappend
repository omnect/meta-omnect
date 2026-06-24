FILESEXTRAPATHS:prepend := "${THISDIR}/u-boot:${LAYERDIR_omnect}/recipes-bsp/u-boot/u-boot:${LAYERDIR_core}/recipes-bsp/u-boot/files:"

SRC_URI += " \
    file://add-reset-info.patch \
    file://omnect_env.patch \
    file://silent_console_early.patch \
    file://boot_retry.cfg \
    file://disable_android_boot_image.cfg \
    file://disable-nfs.cfg \
    file://disable-squashfs.cfg \
    file://disable-usb.cfg \
    file://do_not_use_default_bootcommand.cfg \
    file://enable-gpt.cfg \
    file://enable_dm_rng.cfg \
    file://enable_generic_console_fs_cmds.cfg \
    file://enable-reset-info-cmd-fragment.cfg \
    file://enable-pxe-cmd.cfg \
    file://lock-env.cfg \
    file://redundant-env.cfg \
    file://reloc_gd_env.cfg \
    file://silent_console.cfg \
    file://omnect_env.h \
    file://omnect_env_phycore_imx8mm.h \
    file://omnect_env.env \
    file://phycore_imx8mm.env \
"

CVE_PRODUCT = "u-boot-phytec-imx u-boot"
CVE_VERSION = "${@d.getVar("PV").split('-')[0]}"

OMNECT_BOOTLOADER_CHECKSUM_FILES = "${OMNECT_BOOTLOADER_RECIPE_PATH}"

inherit omnect_uboot_configure_env omnect_bootloader

# wrynose's SWIG 4.3 made SWIG_Python_AppendOutput take a 3rd arg; U-Boot 2024.04's
# bundled dtc/pylibfdt predates that, so its pylibfdt build fails to compile. Switch
# to the version-agnostic SWIG_AppendOutput macro (the upstream dtc 1.7.2 fix).
do_configure:prepend() {
    if [ -f ${S}/scripts/dtc/pylibfdt/libfdt.i_shipped ]; then
        sed -i 's/SWIG_Python_AppendOutput/SWIG_AppendOutput/g' ${S}/scripts/dtc/pylibfdt/libfdt.i_shipped
    fi

    # binman aborts at import time on wrynose: pkg_resources is no longer shipped
    # by the newer setuptools. Switch the two call sites to importlib.resources
    # (already imported by control.py), matching upstream U-Boot's post-2024.04 fix.
    if [ -f ${S}/tools/binman/control.py ]; then
        sed -i \
            -e '/^import pkg_resources$/d' \
            -e "s|pkg_resources.resource_string(__name__, 'missing-blob-help')|importlib.resources.files(__package__).joinpath('missing-blob-help').read_bytes()|" \
            -e "s|pkg_resources.resource_listdir(__name__, 'etype')|[e.name for e in importlib.resources.files(__package__).joinpath('etype').iterdir() if e.is_file()]|" \
            ${S}/tools/binman/control.py
    fi
}

do_configure:prepend:mx8mm-nxp-bsp() {
    cp -f ${UNPACKDIR}/omnect_env_phycore_imx8mm.h ${S}/include/configs/omnect_env_machine.h
    cp -f ${UNPACKDIR}/phycore_imx8mm.env ${S}/board/phytec/phycore_imx8mm/phycore_imx8mm.env
}

# wrynose's oe-core u-boot.inc dropped the UBOOT_NAME mechanism that used to
# deploy the raw u-boot.bin as u-boot-${MACHINE}.bin-${type}. With UBOOT_BINARY
# set to flash.bin, oe-core now deploys only flash.bin, so imx-boot-phytec
# (imx-mkimage) can't find the raw u-boot it stitches into the boot image.
# Deploy it ourselves, mirroring the recipe's own u-boot-nodtb.bin deploy.
do_deploy:append:mx8m-generic-bsp() {
    for config in ${UBOOT_MACHINE}; do
        i=$(expr $i + 1)
        for type in ${UBOOT_CONFIG}; do
            j=$(expr $j + 1)
            if [ $j -eq $i ]; then
                install -m 0644 ${B}/${config}-${type}/u-boot.bin \
                    ${DEPLOYDIR}/u-boot-${MACHINE}.bin-${type}
            fi
        done
        unset j
    done
    unset i
}
