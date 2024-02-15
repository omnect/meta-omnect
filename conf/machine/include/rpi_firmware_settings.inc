# enable serial interface
ENABLE_UART = "1"

# build cmdline.txt
# overwrite CMDLINE_ROOTFS from meta-raspberrypi, we set "root" in boot.scr
CMDLINE_ROOTFS = ""
DISABLE_RPI_BOOT_LOGO = "1"
# prepend before uart console to prioritize serial console output of stdout
CMDLINE:prepend:pn-rpi-cmdline = "console=tty0 "
