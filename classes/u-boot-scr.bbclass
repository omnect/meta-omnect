DEPENDS = "u-boot-mkimage-native"
COMPATIBLE = "rpi"

python create_boot_cmd () {
    append=d.getVar("APPEND")
    boot_cmd=d.getVar("KERNEL_BOOTCMD")
    boot_cmd_file=d.getVar("WORKDIR") + "/boot.cmd"
    fdt_load_script_file=d.getVar("WORKDIR") + "/fdt-load.cmd"
    device_tree=d.getVar("KERNEL_DEVICETREE_FN")
    fdt_addr=d.getVar("UBOOT_FDT_ADDR")
    fdt_load=d.getVar("UBOOT_FDT_LOAD")
    kernel_imagetype=d.getVar("KERNEL_IMAGETYPE")
    omnect_initramfs_fs_type=d.getVar("OMNECT_INITRAMFS_FSTYPE")
    omnect_boot_scr_test_cmds=d.getVar("OMNECT_BOOT_SCR_TEST_CMDS")

    # possibly load device tree from file
    if fdt_load:
        try:
            with open(fdt_load_script_file, "w") as f:
                f.write("\n")
                f.write("echo \"Loading Device Tree: boot/%s\"\n" % (device_tree))
                f.write("load ${devtype} ${devnum}:${bootpart} ${%s} boot/%s\n" % (fdt_addr,device_tree))
        except OSError:
            bb.fatal("Unable to open fdt-load.cmd")

    try:
        with open(boot_cmd_file, "w") as f:
            f.write("\n")

            # echo bootmedium and device
            f.write("echo \"Boot script loaded from ${devtype} ${devnum}\"\n")

            # load device tree
            f.write("fdt addr ${%s}\n" % fdt_addr)

            # in the case of test boot script
            if omnect_boot_scr_test_cmds:
                f.write("%s\n" % (omnect_boot_scr_test_cmds))

            # possibly create "bootpart" env var
            f.write("if env exists bootpart;then echo Booting from bootpart=${bootpart};else setenv bootpart 2;saveenv;echo bootpart not set, default to bootpart=${bootpart};fi\n")

            # TODO optionally allow to load device tree overlays, e.g. disable
            # spi and eth on polis or tauri-l:
            #
            # fdt resize
            # setexpr fdtovaddr ${fdt_addr_r} + F000
            # load ${devtype} ${devnum}:${bootpart} ${fdtovaddr} /boot/imx8mm-phycore-no-spiflash.dtbo && fdt apply ${fdtovaddr}
            # load ${devtype} ${devnum}:${bootpart} ${fdtovaddr} /boot/imx8mm-phycore-no-eth.dtbo && fdt apply ${fdtovaddr}

            # load kernel
            f.write("load ${devtype} ${devnum}:${bootpart} ${kernel_addr_r} boot/%s.bin\n" % kernel_imagetype)

            # load initrd
            f.write("load ${devtype} ${devnum}:${bootpart} ${ramdisk_addr_r} boot/initramfs.%s\n" % omnect_initramfs_fs_type)

            # assemble bootargs: from device tree + extra-bootargs for debugging purpose
            f.write("fdt get value bootargs /chosen bootargs\n")
            f.write("setenv bootargs \"root=/dev/${devtype}blk${devnum}p${bootpart} ${bootargs} %s ${extra-bootargs}\"\n" % append)

            # boot
            f.write("%s ${kernel_addr_r} ${ramdisk_addr_r} ${%s}\n" % (boot_cmd, fdt_addr))
    except OSError:
        bb.fatal("Unable to open boot.cmd")
}

do_compile[prefuncs] += "create_boot_cmd"

do_compile() {
    mkimage -A ${UBOOT_ARCH} -T script -C none -n "${DISTRO_NAME} (${DISTRO_VERSION}) u-boot:\n" -d "${WORKDIR}/boot.cmd" ${OMNECT_BOOT_SCR_NAME}
    if [ ${UBOOT_FDT_LOAD} -eq 1 ]; then
        mkimage -A ${UBOOT_ARCH} -T script -C none -n "${DISTRO_NAME} (${DISTRO_VERSION}) u-boot:\n" -d "${WORKDIR}/fdt-load.cmd" ${OMNECT_FDT_LOAD_NAME}
    fi
}

do_deploy() {
    install -m 0644 -D ${OMNECT_BOOT_SCR_NAME} ${DEPLOYDIR}
    if [ ${UBOOT_FDT_LOAD} -eq 1 ]; then
        install -m 0644 -D ${OMNECT_FDT_LOAD_NAME} ${DEPLOYDIR}
    fi
}

addtask do_deploy after do_compile before do_build

INHIBIT_DEFAULT_DEPS = "1"
