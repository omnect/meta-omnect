FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://rpi-always-set-fdt_addr-with-firmware-provided-FDT-address.patch \
    file://set-config_mmc_env_dev.patch \
"

# for rpi4, add support for ethernet bcmgenet (upstream patches)
# kirkstone: support for bcmgenet now present in u-boot
#SRC_URI:append:raspberrypi4-64 = "\
#    file://net-Add-support-for-Broadcom-GENETv5-Ethernet-controller.patch \
#    file://net-bcmgenet-Don-t-set-ID_MODE_DIS-when-not-using-RGII.patch \
#    file://bcmgenet-fix-DMA-buffer-management.patch \
#    file://bcmgenet-Add-support-for-rgmii-rxid.patch \
#    file://rpi4-Update-memory-map-to-accommodate-scb-devices.patch \
#    file://rpi4-shorten-a-mapping-for-the-DRAM.patch \
#    file://enable-genet-ethernet-fragment.cfg \
#"

SRC_URI:append:raspberrypi4-64 = "\
    file://add-reset-info-config.patch \
    file://add-reset-info-cmd.patch \
    file://enable-reset-info-cmd-fragment.cfg \
"
