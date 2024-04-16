do_compile:prepend() {
    export LLVM_CONFIG_PATH="${STAGING_LIBDIR_NATIVE}/llvm-rust/bin/llvm-config"
    export BINDGEN_EXTRA_CLANG_ARGS="${TUNE_CCARGS}"

    export AZURESDK_PATH=${STAGING_DIR_TARGET}/usr/
    export UUID_PATH=${STAGING_DIR_TARGET}/usr/
    export OPENSSL_PATH=${STAGING_DIR_TARGET}/usr/
    export CURL_PATH=${STAGING_DIR_TARGET}/usr/
}
