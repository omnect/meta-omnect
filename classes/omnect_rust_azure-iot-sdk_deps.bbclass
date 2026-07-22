# wrynose dropped the custom rust-llvm (which carried clang); bindgen now gets
# libclang from oe-core's clang-native.
DEPENDS:append = " clang-native"

do_compile:prepend() {
    export LIBCLANG_PATH="${STAGING_LIBDIR_NATIVE}"
    export BINDGEN_EXTRA_CLANG_ARGS="--target=${TARGET_SYS} --sysroot=${STAGING_DIR_TARGET}"
    # 32-bit ARM hard-float: the gnueabi triple defaults clang to soft-float, so
    # it picks the wrong glibc ABI stubs header (gnu/stubs-soft.h, absent in a
    # hard-float sysroot). Append the tune flags (-mfloat-abi=hard/-mfpu) so
    # clang matches the target ABI. aarch64/x86 have no such ambiguity.
    if [ "${TARGET_ARCH}" = "arm" ]; then
        export BINDGEN_EXTRA_CLANG_ARGS="${BINDGEN_EXTRA_CLANG_ARGS} ${TUNE_CCARGS}"
    fi

    export AZURESDK_PATH=${STAGING_DIR_TARGET}/usr/
    export UUID_PATH=${STAGING_DIR_TARGET}/usr/
    export OPENSSL_PATH=${STAGING_DIR_TARGET}/usr/
    export CURL_PATH=${STAGING_DIR_TARGET}/usr/
}
