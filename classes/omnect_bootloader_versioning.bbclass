python  do_bootloader_checksum() {
    import glob
    import hashlib


    checksum_files = d.getVar("OMNECT_BOOTLOADER_CHECKSUM_FILES").split(" ")
    checksum_files_ignore = []
    checksum_files_ignore_str = d.getVar("OMNECT_BOOTLOADER_CHECKSUM_FILES_GLOB_IGNORE")
    if checksum_files_ignore_str:
        checksum_files_ignore = checksum_files_ignore_str.split(" ")

    used_checksum_file_list = []
    checksum_list = []

    for checksum_file in checksum_files:
        checksum_glob_files = glob.glob(checksum_file)
        if checksum_file and not checksum_glob_files:
            bb.fatal("couldn't handle checksum_file: %s" % checksum_file)

        bb.debug(2, "checksum_file: %s, checksum_glob_files: %s" % (checksum_file, checksum_glob_files))
        for checksum_glob_file in checksum_glob_files:
            if checksum_glob_file in checksum_files_ignore:
                continue
            try:
                with open(checksum_glob_file, "rb") as f:
                    digest = hashlib.file_digest(f, "sha256")
                    used_checksum_file_list.append(checksum_glob_file)
                    checksum_list.append(digest.digest())
            except OSError:
                bb.fatal("Unable to open \"%s\"" % (checksum_glob_file))

    m = hashlib.sha256()
    for checksum in checksum_list:
        m.update(checksum)
    version_checksum = m.hexdigest()

    # check if we should override version_checksum
    version_checksum_override = d.getVar("OMNECT_BOOTLOADER_CHECKSUM_COMPATIBLE")
    if version_checksum_override:
        version_checksum_override_list = version_checksum_override.split(" ",1)
        if version_checksum_override_list[0] == version_checksum:
            bb.debug(1, "overriding version_checksum %s -> %s" % (version_checksum,version_checksum_override_list[1]))
            version_checksum = version_checksum_override_list[1]

    omnect_bootloader_version = d.getVar("PV") + "-" + version_checksum
    d.setVar("OMNECT_BOOTLOADER_VERSION", omnect_bootloader_version)
    bootloader_version_file = d.getVar("WORKDIR") + "/omnect_bootloader_version"
    try:
        with open( bootloader_version_file, "w" ) as f:
            f.write("%s" % omnect_bootloader_version)
    except OSError:
        bb.fatal("Unable to open \"%s\"" % (bootloader_version_file))

    # bb.debug is shown when using param -D (1) or -DD (2)
    bb.debug(1,"version_checksum: %s" % version_checksum)
    bb.debug(1, "used_checksum_file_list: %s" % used_checksum_file_list)
    bb.debug(2, "checksum_list: %s" % checksum_list)
    bb.debug(2, "checksum_files: %s" % checksum_files)
    bb.debug(2, "checksum_files_ignore; %s" % checksum_files_ignore)

}

# OMNECT_BOOTLOADER_CHECKSUM_COMPATIBLE is not part of the recipe or bbclass files
# (set in machine config files)
do_bootloader_checksum[vardeps] = "OMNECT_BOOTLOADER_CHECKSUM_COMPATIBLE"
addtask do_bootloader_checksum after do_unpack before do_configure


do_deploy:append() {
    install -m 0644 -D ${WORKDIR}/omnect_bootloader_version ${DEPLOYDIR}/bootloader_version
}
addtask do_deploy after do_compile before do_build
