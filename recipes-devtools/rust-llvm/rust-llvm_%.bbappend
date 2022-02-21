# we need this to get rust-bindgen to work at runtime
EXTRA_OECMAKE:append:class-native = " -DLLVM_ENABLE_PROJECTS=clang"
