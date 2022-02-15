# BSP Features
| device |  wifi | bluetooth | rtc | tpm | gpt partition | pxe boot | flash mode | sdcard boot | uart (uboot + linux) | PoR detect |
|-|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| [raspberrypi4-64](https://www.raspberrypi.org/) |  x | x | o? | o¹ | x | x | x | x | x | x |
| [raspberrypi3](https://www.raspberrypi.org/) |  x | x | o? | o¹ | ? | ? | ? | x | x | ?
| [phyboard-polis-imx8mm-4](https://www.phytec.eu/product-eu/single-board-computer/phyboard-polis/) |  x | x | x | x | ? | ? | ? | x | x | ? |

| | |
|-|-:|
|x| supported |
|o| optional with extra hardware |
|?| untested |
|-| no |

| | |
|-|-:|
|¹|  SLB9670 TPM2.0|
