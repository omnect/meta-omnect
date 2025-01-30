# This class is used to compute a checksum over all input files of the
# bootloader artefact used in wic image resp. swupdate image.
# This checksum is appended to the upstream bootloader version
# (e.g. u-boot,u-boot-imx, grub).
#
# Note: Input files can be located out of upstream bootloader context,
# e.g. the raspberry-pi bootloader artefact contains u-boot + rpi bootfiles
# + rpi firmware config files.
#
# This class writes two files to `DEPLOY_DIR_IMAGE`:
# - omnect_bootloader_version - contains full bootloader version string
# - omnect_bootloader_checksums.txt - list of used input files and their
#   corresponding sha256 checksums
#
# This class uses the following environment variables:
# - `OMNECT_BOOTLOADER_CHECKSUM_FILES` - list of input files (full path),
#   wildcards are allowed
# - `OMNECT_BOOTLOADER_CHECKSUM_FILES_GLOB_IGNORE` - list of files removed from
#   `OMNECT_BOOTLOADER_CHECKSUM_FILES`, wildcards are not allowed
# - `OMNECT_BOOTLOADER_CHECKSUM_COMPATIBLE` - use this if you want to mark the
#   bootloader version with the current computed checksum compatible to a
#   previous bootloader version checksum, e.g. changes in input files were only
#   formatting. The Format is "<new checksum><:space:><old checksum>".
# - `OMNECT_BOOTLOADER_CHECKSUM_EXPECTED` - expected checksum, if this variables
#   content is different from the computed checksum, the build will fail
#   note: if `OMNECT_BOOTLOADER_CHECKSUM_COMPATIBLE` is set, this var should be
#         set to <old checksum>
# - `OMNECT_BOOTLOADER_RECIPE_PATH` - path of bootloader recipe (mandatory)
# - `OMNECT_BOOTLOADER_VERSION_CHECK_DISABLE` - disable fatal error when version
#   check fails. (still produces an error.)

# create omnect_bootloader_version on recipe parse
python() {
    import glob
    import hashlib
    import os
    from pathlib import Path

    file = d.getVar("FILE")
    bootloader_file = d.getVar("OMNECT_BOOTLOADER_RECIPE_PATH")
    if not bootloader_file:
        bb.fatal("OMNECT_BOOTLOADER_RECIPE_PATH not set")
    # OMNECT_BOOTLOADER_RECIPE_PATH is part of OMNECT_BOOTLOADER_CHECKSUM_FILES
    # we test the bootloader recipe, if it matches this path

    checksum_files = d.getVar("OMNECT_BOOTLOADER_CHECKSUM_FILES").split(" ")
    checksum_files_ignore = []
    checksum_files_ignore_str = d.getVar("OMNECT_BOOTLOADER_CHECKSUM_FILES_GLOB_IGNORE")
    if checksum_files_ignore_str:
        checksum_files_ignore = checksum_files_ignore_str.split(" ")

    # we may have no workdir at parsetime -> create directly in DEPLOY_DIR_IMAGE
    Path(d.getVar("DEPLOY_DIR_IMAGE")).mkdir(parents=True, exist_ok=True)

    checksums_file_out = Path(d.getVar("DEPLOY_DIR_IMAGE") + "/omnect_bootloader_checksums.txt").open('w')

    used_checksum_file_list = []
    checksum_list = []

    for checksum_file in checksum_files:
        # we have to sort since the result of glob is non deterministic on different machines
        checksum_glob_files = sorted(glob.glob(checksum_file))
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
                    checksums_file_out.write("%s %s\n" % (digest.hexdigest(),checksum_glob_file))

            except OSError:
                bb.fatal("Unable to open \"%s\"" % (checksum_glob_file))
    checksums_file_out.close()
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

    version_checksum_expected = d.getVar("OMNECT_BOOTLOADER_CHECKSUM_EXPECTED")
    if not version_checksum_expected:
        bb.fatal("OMNECT_BOOTLOADER_CHECKSUM_EXPECTED not set; computed checksum is: \"%s\"" % version_checksum)
    if version_checksum_expected != version_checksum:
        if "1" != d.getVar("OMNECT_BOOTLOADER_VERSION_CHECK_DISABLE"):
            bb.fatal("expected bootloader checksum (OMNECT_BOOTLOADER_CHECKSUM_EXPECTED): \"%s\" is different from computed: \"%s\"" % (version_checksum_expected, version_checksum))
        else:
            bb.error("expected bootloader checksum (OMNECT_BOOTLOADER_CHECKSUM_EXPECTED): \"%s\" is different from computed: \"%s\"" % (version_checksum_expected, version_checksum))

    bootloader_checksum_file = d.getVar("DEPLOY_DIR_IMAGE") + "/omnect_bootloader_checksum"
    try:
        with open( bootloader_checksum_file, "w" ) as f:
            f.write("%s" % version_checksum)
    except OSError:
        bb.fatal("Unable to open \"%s\"" % (bootloader_checksum_file))

    # bb.debug is shown when using param -D (1) or -DD (2)
    bb.debug(1,"version_checksum: %s" % version_checksum)
    bb.debug(1, "used_checksum_file_list: %s" % used_checksum_file_list)
    bb.debug(2, "checksum_list: %s" % checksum_list)
    bb.debug(2, "checksum_files: %s" % checksum_files)
    bb.debug(2, "checksum_files_ignore; %s" % checksum_files_ignore)
}
