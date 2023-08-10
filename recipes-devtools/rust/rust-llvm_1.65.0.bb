# check src/llvm-project/llvm/CMakeLists.txt for llvm version in use
#
LLVM_RELEASE = "14.0.5"
require rust-sources.inc
require recipes-devtools/rust/rust-llvm.inc
