RPI_EXTRA_CONFIG += "\n#Enable memory reservation for pstore/ramoops\n\
dtoverlay=ramoops-pi4\n\
dtparam=record-size=0x1000\n\
dtparam=console-size=0x10000\n\
dtparam=pmsg-size=0x4000\n\
dtparam=ecc-size=1\n\
dtparam=\n"

KERNEL_DEVICETREE:append:rpi = " overlays/ramoops-pi4.dtbo"
CMDLINE:append:pn-rpi-cmdline = " ramoops.dump_oops=1 ramoops.ecc=1 printk.always_kmsg_dump=Y crash_kexec_post_notifiers=Y"
