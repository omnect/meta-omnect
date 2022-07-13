CARGO_NET_OFFLINE ?= "true"

verify_frozen() {
    cd ${S}/${CARGO_WORKSPACE_ROOT}; cargo verify-project --frozen || bberror "Cargo.lock not uptodate"
}

do_configure:prepend() {
    verify_frozen

    # patch
    marker="# ics_dm_rust_azure-iot-sdk_deps.bbclass:"
    if [ -z "$(grep "${marker}" "${S}/${CARGO_WORKSPACE_ROOT}/Cargo.toml")" ]; then

cat <<EOF >> "${S}/${CARGO_WORKSPACE_ROOT}/Cargo.toml"

${marker}
[patch.'ssh://git@github.com/ICS-DeviceManagement/azure-iot-sdk.git']
azure-iot-sdk = { path = "${WORKDIR}/azure-iot-sdk" }

[patch.'ssh://git@github.com/ICS-DeviceManagement/eis-utils.git']
eis-utils = { path = "${WORKDIR}/eis-utils" }

[patch.'ssh://git@github.com/ICS-DeviceManagement/azure-iot-sdk-sys.git']
azure-iot-sdk-sys = { path = "${WORKDIR}/azure-iot-sdk-sys" }

[patch.'ssh://git@github.com/ICS-DeviceManagement/sd-notify.git']
sd-notify = { path = "${WORKDIR}/sd-notify" }

[patch.'https://git@github.com/Azure/iot-identity-service.git']
aziot-cert-client-async = { path = "${WORKDIR}/aziot-cert-client-async/cert/aziot-cert-client-async" }
aziot-cert-common = { path = "${WORKDIR}/aziot-cert-client-async/cert/aziot-cert-common" }
aziot-cert-common-http = { path = "${WORKDIR}/aziot-cert-client-async/cert/aziot-cert-common-http" }
aziot-certd-config = { path = "${WORKDIR}/aziot-cert-client-async/cert/aziot-certd-config" }
aziot-identity-client-async = { path = "${WORKDIR}/aziot-cert-client-async/identity/aziot-identity-client-async" }
aziot-identity-common = { path = "${WORKDIR}/aziot-cert-client-async/identity/aziot-identity-common" }
aziot-identity-common-http = { path = "${WORKDIR}/aziot-cert-client-async/identity/aziot-identity-common-http" }
aziot-identityd-config = { path = "${WORKDIR}/aziot-cert-client-async/identity/aziot-identityd-config" }
aziot-key-client-async = { path = "${WORKDIR}/aziot-cert-client-async/key/aziot-key-client-async" }
aziot-key-common = { path = "${WORKDIR}/aziot-cert-client-async/key/aziot-key-common" }
aziot-key-common-http = { path = "${WORKDIR}/aziot-cert-client-async/key/aziot-key-common-http" }
aziot-keyd-config = { path = "${WORKDIR}/aziot-cert-client-async/key/aziot-keyd-config" }
EOF
    fi
}

do_compile:prepend() {
    export LLVM_CONFIG_PATH="${STAGING_LIBDIR_NATIVE}/llvm-rust/bin/llvm-config"
    export BINDGEN_EXTRA_CLANG_ARGS="${TUNE_CCARGS}"

    export LIB_PATH_AZURESDK=${STAGING_DIR_TARGET}/usr/
    export LIB_PATH_UUID=${STAGING_DIR_TARGET}/usr/
    export LIB_PATH_OPENSSL=${STAGING_DIR_TARGET}/usr/
    export LIB_PATH_CURL=${STAGING_DIR_TARGET}/usr/
}
