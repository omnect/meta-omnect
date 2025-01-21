KERNEL_DEVICETREE:append:rpi = " overlays/tpm-slb9670.dtbo"
KERNEL_MODULE_AUTOLOAD += "tpm_tis_spi"
