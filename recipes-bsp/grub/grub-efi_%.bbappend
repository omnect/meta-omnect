PROVIDES:omnect_grub = "virtual/bootloader"

inherit omnect_bootloader

GRUB_BUILDIN:append = " echo"