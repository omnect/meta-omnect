# check src/llvm-project/llvm/CMakeLists.txt for llvm version in use
#
LLVM_RELEASE = "17.0.4"
require ${LAYERDIR_core}/recipes-devtools/rust/rust-source.inc
require rust-source.inc
require recipes-devtools/rust/rust-llvm.inc
