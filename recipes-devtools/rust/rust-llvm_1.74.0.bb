# check src/llvm-project/llvm/CMakeLists.txt for llvm version in use
#
LLVM_RELEASE = "17.0.4"
require rust-source.inc
require rust-llvm.inc

FILESEXTRAPATHS:prepend := "${LAYERDIR_core}/recipes-devtools/rust/rust-llvm:"
