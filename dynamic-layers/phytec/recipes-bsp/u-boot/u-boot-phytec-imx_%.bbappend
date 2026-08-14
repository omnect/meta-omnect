FILESEXTRAPATHS:prepend := "${THISDIR}/u-boot:${LAYERDIR_omnect}/recipes-bsp/u-boot/u-boot:${LAYERDIR_core}/recipes-bsp/u-boot/files:"

SRC_URI += " \
    file://add-reset-info.patch \
    file://omnect_env.patch \
    file://silent_console_early.patch \
    file://binman-migrate-pkg_resources-to-importlib.patch \
    file://pylibfdt-use-SWIG_AppendOutput.patch \
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

# --- OMNECT DDR-corruption fix (phyGATE-Tauri-L-iMX8MM) ---
# u-boot-phytec-imx phy25 regenerated board/phytec/phycore_imx8mm/lpddr4_timing.c
# with DDR Tool v3.6.0 (new base dram_timing struct, DBI on, single freq point)
# and added an EEPROM-revision-driven Rev6/Rev7 timing split. On this 2GB SoM the
# regenerated timings are marginal and corrupt DRAM under Linux load. phy23 - the
# last rev before that rewrite - selects timings purely by DRAM size and uses a
# single, known-good base timing set (proven good via the bootloader swap test).
# Forcing the phy25 Rev6 path did NOT help because both phy25 paths use the new
# regenerated base values, not phy23's. Pin the u-boot source back to phy23; the
# phy23..phy25 delta is only the DDR-timing rewrite + an irrelevant polis-rdk DTS
# sync, so nothing else is lost.
SRCREV:mx8mm-nxp-bsp = "a429a8f5162ad1e90aef9ebb6ed79e90cc2cbf11"

OMNECT_BOOTLOADER_CHECKSUM_FILES = "${OMNECT_BOOTLOADER_RECIPE_PATH}"

inherit omnect_uboot_configure_env omnect_bootloader

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
