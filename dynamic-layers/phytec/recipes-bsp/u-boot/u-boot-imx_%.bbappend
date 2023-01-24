FILESEXTRAPATHS:prepend := "${THISDIR}/u-boot:"
FILESEXTRAPATHS:prepend := "${LAYERDIR_omnect}/recipes-bsp/u-boot/u-boot:"
SRC_URI += "\
    file://enable_boot_script.patch\
    file://add-reset-info.patch\
    ${@bb.utils.contains('OMNECT_RELEASE_IMAGE', '1', 'file://silent_console.patch', '', d)}\
    file://enable_generic_console_fs_cmds.cfg\
    file://enable-reset-info-cmd-fragment.cfg\
    file://enable-pxe-cmd.cfg\
    file://silent_console.cfg\
"
