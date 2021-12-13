FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://rfkill.cfg \
    file://unix_domain_sockets.cfg \
"

# when 'imx-sdma' is build into kernel, the firmware loading fails multiple
# times and is loaded very late (after one minute). reason is that at time when
# the kernel first initializes 'imx-sdma' the filesystem is not ready to provide
# the corresponding firmware. we can not build the firmware into the kernel,
# because of the firmware's license.
# when we build 'imx-sdma' as module, the filesystem is ready to provide the
# firmware as soon as the module loads, because the module itself lies in the
# filesystem.
# analog problem applies to hci_uart and cfg80211
SRC_URI += " \
    file://cfg80211-as-module.cfg \
    file://hci_uart-as-module.cfg \
    file://imx-sdma-as-module.cfg \
"
