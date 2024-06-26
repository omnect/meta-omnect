# This class implements a function to embed u-boot version in bootloader
# binary.
#
# Actually it is the other way round: the built binary gets extended to place
# the version information into the newly allocated space at the configured
# offset.
#
# There are two cases of bootloader binaries:
#  - binary blob directly written to flash space at a certain offset
#    (common U-Boot case)
#  - binary file in boot filesystem
#    (special Raspberry Pi case where 2nd stage bootloader resides in
#     kernel8.img)
#
# The bootloader version itself doesn't get computed here but in class
# omnect_bootloader_versioning.bbclass which also writes the computed version
# to file omnect_bootloader_version in DEPLOY_DIR_IMAGE.
#
# The following bitbake variables control how the version information gets
# embedded:
#  - OMNECT_BOOTLOADER_EMBEDDED_VERSION_BBTARGET
#    defines the bitbake target the versioned bootloader binary bases upon
#  - OMNECT_BOOTLOADER_EMBEDDED_VERSION_BINFILE
#    the name of the base binary bootloader file; the generated file will be at
#    the same path but with a suffix '.versioned', the original file gets
#    suffixed with '.unversioned' and a link gets created from the original
#    file name to the '.versioned' file so that subsequent processes take the
#    correct file as input.
#  - OMNECT_BOOTLOADER_EMBEDDED_VERSION_TYPE
#    this can be either "file" or "flash", defining of which type the binary is
#  - OMNECT_BOOTLOADER_EMBEDDED_VERSION_PARAMSIZE
#    number of bytes to reserve for version information
#    (and maybe others in future)
#  - OMNECT_BOOTLOADER_EMBEDDED_VERSION_IMAGESIZE
#    final size of bootloader binary including version information block.
#    this parameter is only used for "flash" type bootloaders which have a
#    pre-defined flash area to reside in, in order to use space at specific
#    offset from end of region
#  - OMNECT_BOOTLOADER_EMBEDDED_VERSION_IMAGEOFFSET
#    only used for type "flash" and only to find correct bootloader location
#    (and hence version information location) during runtime
#  - OMNECT_BOOTLOADER_EMBEDDED_VERSION_IMAGEGZ
#    is set to any value a gzipped version is created, too, during image
#    creation bootloader.bin.versioned.gz is also created
#  - OMNECT_BOOTLOADER_EMBEDDED_VERSION_LOCATION
#    defines the run-time location of the bootloader and is a file path for
#    type "file"; in case boot loader is part of flash it is assumed that it
#    resides in the same device as the root filesystem
#  - OMNECT_BOOTLOADER_EMBEDDED_VERSION_MAGIC
#    a magic number precedes the actual version string, followed by a length
#    byte containing the length of the following string, i.e. w/o magic number
#    and length byte; it is defined as string containing hexadecimal values
#    w/o preceding "0x" (as common in many programming languages), e.g.:
#      "de ad be ef"
#  - OMNECT_BOOTLOADER_EMBEDDED_VERSION_FILLBYTE
#    optionally defines the byte to be used to fill space between original
#    boot loader binary and version data, and also fro end of version data
#    up to defined size of resulting file; default value is 0x00
#    however, for NOR flashes it would be better to have an 0xff, therefore
#    this variable
#
# format of version information is:
#
#    byteoffset: | 0 ... n | (n + 1)  | (n + 2) ... (n + 1 + *n) |
#    ------------+---------+----------+--------------------------+
#    meaning:    | <magic> | <length> | <version string>
#
# where:
#  - <magic> is defined by variable OMNECT_BOOTLOADER_EMBEDDED_VERSION_MAGIC
#  - <length> is one byte specifying length of <version string>
#  - <version string> is the actual version, w/o terminating character
#

# define magic number for embedded bootloader version
OMNECT_BOOTLOADER_EMBEDDED_VERSION_MAGIC = "19 69 02 28"

python omnect_uboot_embed_version() {
    import glob
    import os
    import shutil
    import gzip
    from pathlib import Path

    # read the previously calculated version information
    bootloader_version_file = d.getVar("DEPLOY_DIR_IMAGE") + "/omnect_bootloader_version"
    try:
        with open( bootloader_version_file, "r", encoding="utf-8") as f:
            omnect_bootloader_version = f.read()
    except OSError:
        bb.fatal("Unable to read from bootloader version file \"%s\"" % (bootloader_version_file))

    # be prepared for the case that the one byte version length possibly
    # becomes insufficient! maybe we want to handle most significant bit for
    # length extension to keep that backward compatible.
    if len(omnect_bootloader_version) > 0x7f:
        bb.fatal("FIXME: bootloader version longer than 127 bytes - must take measures for version strings longer than 256 bytes!" % (bootloader_version_file))

    # gather and validate bitbake variables as necessary
    version_type = d.getVar("OMNECT_BOOTLOADER_EMBEDDED_VERSION_TYPE")
    version_file = "bootloader.bin"
    version_paramsize = d.getVar("OMNECT_BOOTLOADER_EMBEDDED_VERSION_PARAMSIZE")
    version_imagesize = d.getVar("OMNECT_BOOTLOADER_EMBEDDED_VERSION_IMAGESIZE")
    version_imagegz   = d.getVar("OMNECT_BOOTLOADER_EMBEDDED_VERSION_IMAGEGZ")
    version_magic = d.getVar("OMNECT_BOOTLOADER_EMBEDDED_VERSION_MAGIC")
    version_fillbyte = d.getVar("OMNECT_BOOTLOADER_EMBEDDED_VERSION_FILLBYTE")

    if version_type == None:
        bb.fatal("Undefined bootlader type variable OMNECT_BOOTLOADER_EMBEDDED_VERSION_TYPE")
    if version_paramsize == None:
        bb.fatal("Undefined bootlader paramsize variable OMNECT_BOOTLOADER_EMBEDDED_VERSION_PARAMSIZE")
    if version_fillbyte == None:
        version_fillbyte = b"\x00"
    else:
        try:
            version_fillbyte = bytearray.fromhex(version_fillbyte)
        except:
            bb.fatal("Cannot convert bootloader version fillbyte  \"%s\" to byte" % (bootloader_version_file))
        if len(version_fillbyte) != 1:
            bb.fatal("Bootloader version fillbyte  \"%s\" is more than one byte" % (bootloader_version_file))

    version_paramsize = int(version_paramsize, 0)
    if version_paramsize < 128 or version_paramsize > 1024:
        bb.fatal("Invalid value for bootlader paramsize variable OMNECT_BOOTLOADER_EMBEDDED_VERSION_PARAMSIZE - must be 128 < %s <= 1024" % version_paramsize)

    # which mode are we running in?
    if version_type != "file" and version_type != "flash":
        bb.fatal("Undefined/unrecognized variable OMNECT_BOOTLOADER_EMBEDDED_VERSION_TYPE value \"%s\"" % version_type)

    # can we access bootloader binary file? it has to be in WORKDIR, by the way
    version_file = d.getVar("WORKDIR") + "/" + version_file
    try:
        st = os.stat(version_file)
    except OSError:
        bb.fatal("Unable to stat bootloader binary \"%s\"" % (version_file))
    filesize = st.st_size

    if version_type == "file":
        expand_size = version_paramsize
        # we want to have some space after last original byte
        if filesize % version_paramsize == 0:
            expand_size = version_paramsize
        else:
            expand_size = version_paramsize - (filesize % version_paramsize)

        version_imagesize = filesize + expand_size + version_paramsize
    else:
        if version_imagesize == None:
            bb.fatal("Undefined bootlader imagesize variable OMNECT_BOOTLOADER_EMBEDDED_VERSION_IMAGESIZE")
        version_imagesize = int(version_imagesize, 0)
        if version_imagesize <= filesize + version_paramsize:
            bb.fatal("Invalid bootlader imagesize variable OMNECT_BOOTLOADER_EMBEDDED_VERSION_IMAGESIZE: %s - must be at least %s" % (version_imagesize, filesize + version_paramsize))

        expand_size = version_imagesize - filesize - version_paramsize

    # 1st make copy of original file
    version_file_new = shutil.copyfile(version_file, version_file + '.versioned')
    written_length = filesize

    # 2nd write version info as parameter block
    with open(version_file_new, 'ab') as f:
        # fill space between original content and parameter block
        f.write(version_fillbyte * expand_size)
        written_length = written_length + expand_size

        # write magic
        version_magic_bytes = bytearray.fromhex(version_magic)
        f.write(version_magic_bytes)
        written_length = written_length + len(version_magic_bytes)

        # write length byte
        length_bytes = int.to_bytes(len(omnect_bootloader_version))
        f.write(length_bytes)
        written_length = written_length + len(length_bytes)

        # write actual version string
        f.write(bytearray(omnect_bootloader_version, "utf-8"))
        written_length = written_length + len(omnect_bootloader_version)

        if written_length < version_imagesize:
            # fill up to desired length
            f.write(version_fillbyte * (version_imagesize - written_length))

    if version_type != "file" and version_imagegz != None and version_imagegz != "":
        with open(version_file_new, 'rb') as f_in:
            with open(version_file_new + '.gz', 'wb') as f_out:
                with gzip.GzipFile(version_file_new, 'wb', fileobj=f_out) as f_out:
                    shutil.copyfileobj(f_in, f_out)
}

do_compile() {
    # this is actually no compilation but only taking advantage of already
    # existing bootloader binary this recipe depends on
    cp "${DEPLOY_DIR_IMAGE}/${OMNECT_BOOTLOADER_EMBEDDED_VERSION_BINFILE}" "${WORKDIR}/bootloader.bin"
}

do_compile[depends] += "${OMNECT_BOOTLOADER_EMBEDDED_VERSION_BBTARGET}:do_deploy "
do_deploy[prefuncs] += "omnect_uboot_embed_version"

do_deploy() {
    install -m 0644 -D ${WORKDIR}/bootloader.bin.versioned ${DEPLOYDIR}/bootloader.versioned.bin
    if [ -r ${WORKDIR}/bootloader.bin.versioned.gz ]; then
        install -m 0644 -D ${WORKDIR}/bootloader.bin.versioned.gz ${DEPLOYDIR}/bootloader.versioned.bin.gz
    fi
}

addtask do_deploy after do_compile before do_build

INHIBIT_DEFAULT_DEPS = "1"
