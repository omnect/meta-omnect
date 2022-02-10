# bsp features
| device |  wifi | bluetooth | rtc | tpm | gpt partition | pxe boot | flash mode | sdcard boot | uart (uboot + linux) | PoR detect |
|-|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| raspberrypi4-64 |  x | x | o? | o¹ | x | x | x | x | x | x |
| raspberrypi3 |  x | x | o? | o¹ | ? | ? | ? | x | x | ?
| phyboard-polis-imx8mm-4 |  x | x | x | x | ? | ? | ? | x | x | ? |

x: supported<br>
o: optional with extra hardware<br>
?: untested<br>
-: no<br>

¹: SLB9670 TPM2.0
