# wrynose dropped the custom rust-llvm (which carried clang); bindgen now gets
# libclang from oe-core's clang-native.
DEPENDS:append = " clang-native"

do_compile:prepend() {
    export LIBCLANG_PATH="${STAGING_LIBDIR_NATIVE}"
    export BINDGEN_EXTRA_CLANG_ARGS="--target=${TARGET_SYS} --sysroot=${STAGING_DIR_TARGET}"

    export AZURESDK_PATH=${STAGING_DIR_TARGET}/usr/
    export UUID_PATH=${STAGING_DIR_TARGET}/usr/
    export OPENSSL_PATH=${STAGING_DIR_TARGET}/usr/
    export CURL_PATH=${STAGING_DIR_TARGET}/usr/
}
