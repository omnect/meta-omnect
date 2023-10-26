# BSP Features
| device                                                                                             | OS bootloader | wifi  | bluetooth |  rtc  |  tpm  | gpt partition | pxe boot | sdcard boot | emmc boot | nvme boot | uart (OS bootloader + linux) | PoR detect | Hardware Watchdog |
| -------------------------------------------------------------------------------------------------- | :-------------: | :---: | :-------: | :---: | :---: | :-----------: | :------: | :---------: | :-------: | :-------: | :------------------: | :--------: | :---------------: |
| [raspberrypi4-64](https://www.raspberrypi.org/)  | uboot | x | x | o? | o¹ | x | x | x | x (cm4) | - | /dev/ttyS0 reserved by os in devel image | x | x |
| [raspberrypi3](https://www.raspberrypi.org/) | uboot | x | x | o? | o¹| - | x  | x | - | -| /dev/ttyS0 reserved by os in devel image | x | x |
| [phyboard-polis-imx8mm-4](https://www.phytec.eu/product-eu/single-board-computer/phyboard-polis/)  | uboot | x | x | x | x | x | x |  x |  ? | - | /dev/ttymxc2 reserved by os in devel image  | x | ? |
| [phygate-tauri-l-imx8mm-2](https://www.phytec.eu/en/produkte/fertige-geraete-oem/phygate-tauri-l/) | uboot | - | - | x | x | x | x | x | x² | - |/dev/ttymxc2 reserved by os in devel image  | x | x |
| [(welotec) eg500](https://www.welotec.com/iot-edge-gateway/) | grub | - | - | ? | x | x | todo | - | - | x³ | no uart reserved for os | - | ? |

|      |                              |
| ---- | ---------------------------: |
| x    |                    supported |
| o    | optional with extra hardware |
| ?    |                     untested |
| -    |                           no |
| todo |      we have to implement it |

|     |                                                                                                                                                                |
| --- | ----------------------------------------------------------------------------------: |
| ¹   |                                                                      SLB9670 TPM2.0 |
| ²   | device path emmc: */dev/mmcblk2* <br/> use DIP switch to select emmc as boot device |
| ³ | device path nvme: */dev/nvme0n1* |
