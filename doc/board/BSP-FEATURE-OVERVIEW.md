# BSP Features
| device                                | OS bootloader | wifi  | bluetooth |  rtc  |  tpm  | gpt partition | pxe boot | sdcard boot | emmc boot | nvme boot |        uart (OS bootloader + linux)        | PoR detect | Hardware Watchdog |
| ------------------------------------- | :-----------: | :---: | :-------: | :---: | :---: | :-----------: | :------: | :---------: | :-------: | :-------: | :----------------------------------------: | :--------: | :---------------: |
| [raspberrypi4-64](RASPBERRY-PI.md)    |     uboot     |   x   |     x     |  -   |  -   |       x       |    x     |      x      |  x (cm4)  |     -     |  /dev/ttyS0 reserved by os in devel image  |     x      |         x         |
| [raspberrypi3](RASPBERRY-PI.md)       |     uboot     |   x   |     x     |  -   |  -   |       -       |    x     |      x      |     -     |     -     |  /dev/ttyS0 reserved by os in devel image  |     x      |         x         |
| [phyboard-polis-imx8mm-4](PHYTEC.md)  |     uboot     |   x   |     x     |   x   |   x   |       x       |    x     |      x      |     ?     |     -     | /dev/ttymxc2 reserved by os in devel image |     x      |         ?         |
| [phygate-tauri-l-imx8mm-2](PHYTEC.md) |     uboot     |   -   |     -     |   x   |   x   |       x       |    x     |      x      |    x     |     -     | /dev/ttymxc2 reserved by os in devel image |     x      |         x         |
| [Welotec Arrakis-pico-MK3](WELOTEC.md)         |     grub      |   -   |     -     |   ?   |   x   |       x       |   todo   |      -      |     -     |    x     |          no uart reserved for os           |     -      |         ?         |

|      |                              |
| ---- | ---------------------------: |
| x    |                    supported |
| ?    |                     untested |
| -    |                           no |
| todo |      we have to implement it |
