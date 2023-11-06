# Phygate Tauri-L (phygate-tauri-l-imx8mm-2)

https://www.phytec.eu/en/produkte/fertige-geraete-oem/phygate-tauri-l/


device path emmc: */dev/mmcblk2* <br/> use DIP switch to select emmc as boot device

omnect features:
-add feature support (dps provisioning (TPM)
- wifi commissioning

rootfs size: ???

- [meta-phytec](https://github.com/phytec/meta-phytec) (optional - via dynamic layer, phytec polis support depends on it)
- [meta-freescale](https://github.com/Freescale/meta-freescale) (optional - via dynamic layer, phytec polis support depends on it)
- [meta-raspberrypi](https://github.com/agherzan/meta-raspberrypi.git) (optional - via dynamic layer, raspberrypi support depends on it)

uart (OS bootloader + linux): /dev/ttymxc2 reserved by os in devel image

## Device Tree Overlays
Available device tree overlays which can be activated e.g. via
```sh
sudo fw_setenv overlays "imx8mm-phygate-tauri-rs232-rs232.dtbo imx8mm-phycore-no-eth.dtbo"
sudo reboot

```
- imx8mm-phygate-tauri-rs232-rs232.dtbo
- imx8mm-phygate-tauri-rs232-rs485.dtbo
- imx8mm-phygate-tauri-rs232-rs485-switchable.dtbo
- imx8mm-phygate-tauri-rs232-rts-cts.dtbo
- imx8mm-phycore-rpmsg.dtbo
- imx8mm-phycore-no-eth.dtbo
- imx8mm-phycore-no-spiflash.dtbo

