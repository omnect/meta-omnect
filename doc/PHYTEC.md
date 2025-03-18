# Phygate Tauri-L (phygate-tauri-l-imx8mm-2)

- **Product Page:** https://www.phytec.eu/en/produkte/fertige-geraete-oem/phygate-tauri-l/
- **BSP (dynamic layer):**  
  - [meta-phytec](https://github.com/phytec/meta-phytec)
  - [meta-freescale](https://github.com/Freescale/meta-freescale)
  - [meta-freescale-distro](https://github.com/Freescale/meta-freescale-distro)
  - [meta-imx](https://github.com/nxp-imx/meta-imx)
- **Boot Media:** use DIP switch to switch between sdcard and emmc as boot device. 
- **Flash internal emmc:**
  - boot *omnect-os* from sdcard
  - use [flash-mode 1](../README.md#flash-mode-1) in order to flash an image from USB to emmc. The emmc device path is */dev/mmcblk2*.
  - use DIP switch to boot from emmc and power on device 
- **UART:** */dev/ttymxc2* is reserved for system console in OMNECT-gateway-devel images.

## Omnect Feature Support:

| Feature | Availability |
| ------------------------------------ | :-------------: |
| **Device Provisioning via**          | x509 or TPM     |
| **OTA Update**                       | yes             |
| **Factory Reset**                    | yes             |
| **Wifi Commissioning via Bluetooth** | no              |
| **LTE Support**                      | no              |
| **omnect_pstore** aka reboot reasons | yes             |

## Device Tree Overlays

Available device tree overlays:
- imx8mm-phygate-tauri-rs232-rs232.dtbo
- imx8mm-phygate-tauri-rs232-rs485.dtbo
- imx8mm-phygate-tauri-rs232-rs485-switchable.dtbo
- imx8mm-phygate-tauri-rs232-rts-cts.dtbo
- imx8mm-phycore-rpmsg.dtbo
- imx8mm-phycore-no-eth.dtbo
- imx8mm-phycore-no-spiflash.dtbo
- imx8mm-phygate-tauri-analog-io.dtbo

Activate overlay example:
```sh
sudo fw_setenv overlays "imx8mm-phygate-tauri-rs232-rs232.dtbo imx8mm-phycore-no-eth.dtbo"
sudo reboot
```
