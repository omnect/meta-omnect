do_configure:append() {

    # patch paths to enable offline builds. cargo_common.bbclass can not handle
    # git dependencies with ssh links well.

    sed -i -e 's/azure-iot-sdk =.*/azure-iot-sdk = { path = \"..\/azure-iot-sdk\", features = ["module_client"] }/' \
           -e 's/sd-notify =.*/sd-notify = { path = \"..\/sd-notify\", optional = true }/' ${S}/Cargo.toml

    sed -i -e 's/azure-iot-sdk-sys =.*/azure-iot-sdk-sys = { path = \"..\/azure-iot-sdk-sys\", default-features = false }/' \
           -e 's/eis-utils =.*/eis-utils = { path = \"..\/eis-utils\", optional = true }/' ${WORKDIR}/azure-iot-sdk/Cargo.toml
}

do_compile:prepend() {
    export LLVM_CONFIG_PATH="${STAGING_LIBDIR_NATIVE}/llvm-rust/bin/llvm-config"
    export BINDGEN_EXTRA_CLANG_ARGS="${TUNE_CCARGS}"

    export LIB_PATH_AZURESDK=${STAGING_DIR_TARGET}/usr/
    export LIB_PATH_UUID=${STAGING_DIR_TARGET}/usr/
    export LIB_PATH_OPENSSL=${STAGING_DIR_TARGET}/usr/
    export LIB_PATH_CURL=${STAGING_DIR_TARGET}/usr/
}
