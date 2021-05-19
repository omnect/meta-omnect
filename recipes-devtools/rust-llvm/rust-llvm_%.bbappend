# we need this to get rust-bindgen to work at runtime
EXTRA_OECMAKE_append_class-native = " -DLLVM_ENABLE_PROJECTS=clang"
