# check src/llvm-project/llvm/CMakeLists.txt for llvm version in use
#
LLVM_RELEASE = "13.0.0"
require rust-sources.inc
require recipes-devtools/rust/rust-llvm.inc
