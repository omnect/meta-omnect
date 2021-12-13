FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# we have to append here, if we add it via += the fragment gets overwritten by
# phytec's docker.cfg fragment.
# docker.cfg activates unix domain sockets as module, but we need it compiled
# into kernel for our initramfs.
SRC_URI:append = " file://unix_domain_sockets.cfg"

# when 'imx-sdma' is build into kernel, the firmware loading fails multiple
# times and is loaded very late (after one minute). reason is that at time when
# the kernel first initializes 'imx-sdma' the filesystem is not ready to provide
# the corresponding firmware. we can not build the firmware into the kernel,
# because of the firmware's license.
# when we build 'imx-sdma' as module, the filesystem is ready to provide the
# firmware as soon as the module loads, because the module itself lies in the
# filesystem.
# analog problem applies to hci_uart and cfg80211
SRC_URI:append = " \
    file://cfg80211-as-module.cfg \
    file://hci_uart-as-module.cfg \
    file://imx-sdma-as-module.cfg \
"

# enable rfkill
SRC_URI:append = " file://rfkill.cfg"
