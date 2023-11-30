inherit cross
require rust-cross.inc
require rust-source.inc

DEPENDS += "virtual/${TARGET_PREFIX}gcc virtual/${TARGET_PREFIX}compilerlibs virtual/libc"
PROVIDES = "virtual/${TARGET_PREFIX}rust"
PN = "rust-cross-${TUNE_PKGARCH}-${TCLIBC}"

LIC_FILES_CHKSUM = "file://COPYRIGHT;md5=c2cccf560306876da3913d79062a54b9"
