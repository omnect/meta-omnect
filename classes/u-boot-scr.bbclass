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
    try:
        with open(boot_cmd_file, "w") as f:
            f.write("\n")

            # create u-boot environment on first boot
            f.write("saveenv\n")

            # possibly create "bootpart" env var
            f.write("if env exists bootpart;then echo Booting from bootpart=${bootpart};else setenv bootpart 2;echo bootpart not set, default to bootpart=${bootpart};fi\n")

            # possibly expand data partition on first boot
            if bb.utils.contains('DISTRO_FEATURES', 'resize-data', 'true', 'false', d):
                f.write("if test -z \"${resized_data}\"; then setenv resize_data \"resize_data=1\";fi\n")

            # possibly mount persitent journal to /var/log/journal
            if bb.utils.contains('DISTRO_FEATURES', 'persistent-journal', 'true', 'false', d):
                bootargs_append+=" persistent_journal=1"

            # load device tree
            f.write("fdt addr ${%s}\n" % fdt_addr)

            # possibly load devicetree from file
            if fdt_load:
                f.write("load mmc 0:${bootpart} ${%s} boot/%s\n" % (fdt_addr,device_tree))

            # load kernel
            f.write("load mmc 0:${bootpart} ${kernel_addr_r} boot/%s-initramfs.bin\n" % kernel_imagetype)

            # assemble bootargs
            f.write("fdt get value bootargs /chosen bootargs\n")
            f.write("setenv bootargs \"${bootargs} bootpart=${bootpart} %s ${resize_data}\"\n" % bootargs_append)

            # boot
            f.write("%s ${kernel_addr_r} - ${%s}\n" % (boot_cmd, fdt_addr))
    except OSError:
        bb.fatal("Unable to open boot.cmd")
}

do_compile[prefuncs] += "create_boot_cmd"
