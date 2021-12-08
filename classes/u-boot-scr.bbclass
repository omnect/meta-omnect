DEPENDS = "u-boot-mkimage-native"
COMPATIBLE = "rpi"

python create_boot_cmd () {
    boot_cmd=d.getVar("KERNEL_BOOTCMD")
    boot_cmd_file=d.getVar("WORKDIR") + "/boot.cmd"
    bootargs_append=""
    bootargs_append_tmp=d.getVar("UBOOT_BOOTARGS_APPEND")
    if bootargs_append_tmp:
        bootargs_append+=bootargs_append_tmp
    device_tree=d.getVar("KERNEL_DEVICETREE_FN")
    fdt_addr=d.getVar("UBOOT_FDT_ADDR")
    fdt_load=d.getVar("UBOOT_FDT_LOAD")
    kernel_imagetype=d.getVar("KERNEL_IMAGETYPE")
    ics_dm_initramfs_fs_type=d.getVar("ICS_DM_INITRAMFS_FSTYPE")
    ics_dm_boot_scr_test_cmds=d.getVar("ICS_DM_BOOT_SCR_TEST_CMDS")
    try:
        with open(boot_cmd_file, "w") as f:
            f.write("\n")

            # echo bootmedium and device
            f.write("echo \"Boot script loaded from ${devtype} ${devnum}\"\n")

            # in the case of test boot script
            if ics_dm_boot_scr_test_cmds:
                f.write("%s\n" % (ics_dm_boot_scr_test_cmds)) 

            # possibly create "bootpart" env var
            f.write("if env exists bootpart;then echo Booting from bootpart=${bootpart};else setenv bootpart 2;saveenv;echo bootpart not set, default to bootpart=${bootpart};fi\n")

            # possibly expand data partition on first boot
            if bb.utils.contains('DISTRO_FEATURES', 'resize-data', True, False, d):
                f.write("if test -z \"${resized_data}\"; then setenv resize_data \"resize_data=1\";fi\n")

            # possibly mount persistent journal to /var/log/
            if bb.utils.contains('DISTRO_FEATURES', 'persistent-var-log', True, False, d):
                bootargs_append+=" persistent_var_log=1"

            # load device tree
            f.write("fdt addr ${%s}\n" % fdt_addr)

            # possibly load device tree from file
            if fdt_load:
                f.write("load ${devtype} ${devnum}:${bootpart} ${%s} boot/%s\n" % (fdt_addr,device_tree))

            # load kernel
            f.write("load ${devtype} ${devnum}:${bootpart} ${kernel_addr_r} boot/%s.bin\n" % kernel_imagetype)

            # load initrd
            f.write("load ${devtype} ${devnum}:${bootpart} ${ramdisk_addr_r} boot/initramfs.%s\n" % ics_dm_initramfs_fs_type)

            # assemble bootargs
            f.write("fdt get value bootargs /chosen bootargs\n")
            f.write("setenv bootargs \"${bootargs} bootpart=${bootpart} %s ${resize_data}\"\n" % bootargs_append)

            # boot
            f.write("%s ${kernel_addr_r} ${ramdisk_addr_r} ${%s}\n" % (boot_cmd, fdt_addr))
    except OSError:
        bb.fatal("Unable to open boot.cmd")
}

do_compile[prefuncs] += "create_boot_cmd"

do_compile() {
    mkimage -A ${UBOOT_ARCH} -T script -C none -n "${DISTRO_NAME} (${DISTRO_VERSION}) u-boot:\n" -d "${WORKDIR}/boot.cmd" ${ICS_DM_BOOT_SCR_NAME}
}

do_deploy() {
    install -m 0644 -D ${ICS_DM_BOOT_SCR_NAME} ${DEPLOYDIR}
}

addtask do_deploy after do_compile before do_build

INHIBIT_DEFAULT_DEPS = "1"
