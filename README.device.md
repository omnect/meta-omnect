# bsp features
| device | wifi | bluetooth | rtos | tpm | gpt partition | pxe boot | flash mode | emmc boot | fspi boot | secure boot |
|-|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| raspberrypi4-64 | x | x | - | x | x | x | x | - | - | - |
| raspberrypi3 | x | x | - | x | ? | ? | ? | - | - | - |
| phyboard-polis-imx8mm-4 | x | x | ? | ? | ? | ? | ? | ? |? | ? |

# todo phyboard-polis-imx8mm-4
 - check if DISTRO_FEATURE "resize-data" works if u-boot is in fspi, and handle
   it accordingly if it doesn't
 - enable choosing between lwb firmware: etsi, fcc, jp
