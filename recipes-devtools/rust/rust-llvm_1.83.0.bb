# check src/llvm-project/llvm/CMakeLists.txt for llvm version in use
#
LLVM_RELEASE = "19.1.1"
require rust-source.inc
require rust-llvm.inc

FILESEXTRAPATHS:prepend := "${LAYERDIR_core}/recipes-devtools/rust/rust-llvm:"
