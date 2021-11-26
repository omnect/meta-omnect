FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://rpi-always-set-fdt_addr-with-firmware-provided-FDT-address.patch \
    file://set-config_mmc_env_dev.patch \
    file://disable-autoload-replaced-by-more-flexible-pxe-boot.patch \
"

# for rpi4, add support for ethernet bcmgenet (upstream patches)
SRC_URI_append_raspberrypi4-64 = "\
    file://net-Add-support-for-Broadcom-GENETv5-Ethernet-controller.patch \
    file://net-bcmgenet-Don-t-set-ID_MODE_DIS-when-not-using-RGII.patch \
    file://bcmgenet-fix-DMA-buffer-management.patch \
    file://bcmgenet-Add-support-for-rgmii-rxid.patch \
    file://rpi4-Update-memory-map-to-accommodate-scb-devices.patch \
    file://rpi4-shorten-a-mapping-for-the-DRAM.patch \
    file://enable-genet-ethernet-fragment.cfg \
"
