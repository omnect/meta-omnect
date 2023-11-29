require recipes-devtools/rust/rust.inc
inherit cross
require recipes-devtools/rust/rust-cross.inc
require ${LAYERDIR_core}/recipes-devtools/rust/rust-source.inc
require rust-source.inc

DEPENDS += "virtual/${TARGET_PREFIX}gcc virtual/${TARGET_PREFIX}compilerlibs virtual/libc"
PROVIDES = "virtual/${TARGET_PREFIX}rust"
PN = "rust-cross-${TUNE_PKGARCH}-${TCLIBC}"
