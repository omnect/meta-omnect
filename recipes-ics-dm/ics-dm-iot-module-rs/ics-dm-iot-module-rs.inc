DEPENDS += "\
    azure-iot-sdk-c\
    libeis-utils\
"

do_compile_prepend() {
# - it seems cargo wants at least to verify that there are no changes
#   in the remote repo in regard to CARGO_HOME
# - for now we use git to fetch the repo instead of cargo itself
# - @ToDo patch cargo.toml file so that it doesnt see a remote ???
export CARGO_NET_GIT_FETCH_WITH_CLI=true

export LLVM_CONFIG_PATH="${STAGING_LIBDIR_NATIVE}/llvm-rust/bin/llvm-config"

export LIB_PATH_AZURESDK=${STAGING_DIR_TARGET}/usr/
export LIB_PATH_EISUTILS=${STAGING_DIR_TARGET}/usr/
export LIB_PATH_UUID=${STAGING_DIR_TARGET}/usr/
export LIB_PATH_OPENSSL=${STAGING_DIR_TARGET}/usr/
export LIB_PATH_CURL=${STAGING_DIR_TARGET}/usr/
}
