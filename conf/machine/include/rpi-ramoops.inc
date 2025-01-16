RPI_EXTRA_CONFIG += "\n#Enable memory reservation for pstore/ramoops\n\
dtoverlay=ramoops-pi4-overlay\n\
dtparam=console-size=0x10000\n\
dtparam=pmsg-size=0x1000\ndtparam=\n"

KERNEL_DEVICETREE:append:rpi = " overlays/ramoops-pi4-overlay.dtbo"
