# BSP Features
| device |  wifi | bluetooth | rtc | tpm | gpt partition | pxe boot | flash mode (todo remove? from table. imho it's not bsp dependend) | sdcard boot | uart (uboot + linux) | PoR detect |
|-|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| [raspberrypi4-64](https://www.raspberrypi.org/) |  x | x | o? | o¹ | x | x | x | x | x | x |
| [raspberrypi3](https://www.raspberrypi.org/) |  x | x | o? | o¹ | - | todo | x | x | x | ?
| [phyboard-polis-imx8mm-4](https://www.phytec.eu/product-eu/single-board-computer/phyboard-polis/) |  x | x | x | x | x | todo | x | x | x | todo |
| [phygate-tauri-l-imx8mm-2](https://www.phytec.eu/en/produkte/fertige-geraete-oem/phygate-tauri-l/) |  ? | ? | ? | ? | ? | todo | ? | ? | ? | todo |

| | |
|-|-:|
|x| supported |
|o| optional with extra hardware |
|?| untested |
|-| no |
|todo| we have to implement it

| | |
|-|-:|
|¹|  SLB9670 TPM2.0|
