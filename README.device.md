# BSP Features
| device                                                                                            | wifi | bluetooth | rtc | tpm | gpt partition | pxe boot | sdcard boot | uart (uboot + linux) | PoR detect |
|-|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| [raspberrypi4-64](https://www.raspberrypi.org/)                                                   | x    | x         | o?  | o¹  | x²            | x        | x           | x               | x          |
| [raspberrypi3](https://www.raspberrypi.org/)                                                      | x    | x         | o?  | o¹  | -             | todo     | x           | x               | ?          |

| | |
|-|-:|
|x| supported |
|o| optional with extra hardware |
|?| untested |
|-| no |
|todo| we have to implement it

| | |
|-|-:|
|¹| SLB9670 TPM2.0|
|²| we don't use it, because the rpi3 doesn't support it. furthermore we would've effort to support both `gpt` and `mbr` in `ics-dm-cli` and `ics-dm-os-initramfs` |
