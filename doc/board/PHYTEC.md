# Phygate Tauri-L (phygate-tauri-l-imx8mm-2)

https://www.phytec.eu/en/produkte/fertige-geraete-oem/phygate-tauri-l/

offically supported

device path emmc: */dev/mmcblk2* <br/> use DIP switch to select emmc as boot device

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

# Phygate Polis (imx8mm-phyboard-polis-4)

https://www.phytec.eu/product-eu/single-board-computer/phyboard-polis/

not officially supported