# BSP Features
| device                                                                                             | wifi | bluetooth | rtc | tpm | gpt partition | pxe boot | sdcard boot | uart (uboot + linux) | PoR detect |
|-|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| [raspberrypi4-64](https://www.raspberrypi.org/)                                                    | x    | x         | o?  | o¹  | x²            | x        | x           | x                    | x          |
| [raspberrypi3](https://www.raspberrypi.org/)                                                       | x    | x         | o?  | o¹  | -             | todo     | x           | x                    | ?          |
| [phyboard-polis-imx8mm-4](https://www.phytec.eu/product-eu/single-board-computer/phyboard-polis/)  | x    | x         | x   | x   | x²            | todo     | x           | x                    | todo       |
| [phygate-tauri-l-imx8mm-2](https://www.phytec.eu/en/produkte/fertige-geraete-oem/phygate-tauri-l/) | ?    | ?         | ?   | ?   | ?             | todo     | ?           | ?                    | todo       |

| |  |
|-|-:|
|x| supported |
|o| optional with extra hardware |
|?| untested |
|-| no |
|todo| we have to implement it |

| |  |
|-|-:|
|¹| SLB9670 TPM2.0|
|²| we don't use it, because the rpi3 doesn't support it. furthermore we would've effort to support both `gpt` and `mbr` in `ics-dm-cli` and `ics-dm-os-initramfs` |
