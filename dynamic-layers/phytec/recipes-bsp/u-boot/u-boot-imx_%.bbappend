FILESEXTRAPATHS:prepend := "${THISDIR}/u-boot:"
SRC_URI += "\
    file://enable_boot_script.patch\
    file://add-reset-info.patch\
    file://enable_generic_console_fs_cmds.cfg\
    file://enable-reset-info-cmd-fragment.cfg\
"
