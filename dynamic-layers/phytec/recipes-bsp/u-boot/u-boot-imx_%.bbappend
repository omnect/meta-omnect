FILESEXTRAPATHS_prepend := "${THISDIR}/u-boot:"
SRC_URI += "\
    file://enable_boot_script.patch\
    file://enable_generic_console_fs_cmds.cfg\
"
