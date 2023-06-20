CARGO_NET_OFFLINE ?= "true"

verify_frozen() {
    cd ${S}/${CARGO_WORKSPACE_ROOT}; cargo verify-project --frozen || bberror "Cargo.lock not uptodate"
}

do_configure:prepend() {
    verify_frozen

    # patch
    marker="# omnect_rust_iot-identity-service_deps.bbclass:"
    if [ -z "$(grep "${marker}" "${S}/${CARGO_WORKSPACE_ROOT}/Cargo.toml")" ]; then

cat <<EOF >> "${S}/${CARGO_WORKSPACE_ROOT}/Cargo.toml"

${marker}z
[patch.'https://github.com/Azure/iot-identity-service']
aziot-cert-client-async = { path = "${WORKDIR}/aziot-cert-client-async/cert/aziot-cert-client-async" }
aziot-cert-common = { path = "${WORKDIR}/aziot-cert-client-async/cert/aziot-cert-common" }
aziot-cert-common-http = { path = "${WORKDIR}/aziot-cert-client-async/cert/aziot-cert-common-http" }
aziot-certd-config = { path = "${WORKDIR}/aziot-cert-client-async/cert/aziot-certd-config" }
aziot-identity-client-async = { path = "${WORKDIR}/aziot-cert-client-async/identity/aziot-identity-client-async" }
aziot-identity-common = { path = "${WORKDIR}/aziot-cert-client-async/identity/aziot-identity-common" }
aziot-identity-common-http = { path = "${WORKDIR}/aziot-cert-client-async/identity/aziot-identity-common-http" }
aziot-identityd-config = { path = "${WORKDIR}/aziot-cert-client-async/identity/aziot-identityd-config" }
aziot-key-client = { path = "${WORKDIR}/aziot-cert-client-async/key/aziot-key-client" }
aziot-key-client-async = { path = "${WORKDIR}/aziot-cert-client-async/key/aziot-key-client-async" }
aziot-key-common = { path = "${WORKDIR}/aziot-cert-client-async/key/aziot-key-common" }
aziot-key-common-http = { path = "${WORKDIR}/aziot-cert-client-async/key/aziot-key-common-http" }
aziot-key-openssl-engine = { path = "${WORKDIR}/aziot-cert-client-async/key/aziot-key-openssl-engine" }
aziot-keyd-config = { path = "${WORKDIR}/aziot-cert-client-async/key/aziot-keyd-config" }
aziot-keys-common = { path = "${WORKDIR}/aziot-cert-client-async/key/aziot-keys-common" }
aziotctl-common = { path = "${WORKDIR}/aziot-cert-client-async/aziotctl/aziotctl-common" }
aziot-tpmd-config = { path = "${WORKDIR}/aziot-cert-client-async/tpm/aziot-tpmd-config" }
cert-renewal = { path = "${WORKDIR}/aziot-cert-client-async/cert/cert-renewal" }
http-common = { path = "${WORKDIR}/aziot-cert-client-async/http-common" }
logger = { path = "${WORKDIR}/aziot-cert-client-async/logger" }
test-common = { path = "${WORKDIR}/aziot-cert-client-async/test-common" }
# for config-common we patch iotedge so that it uses the same branch as the rest
config-common = { path = "${WORKDIR}/aziot-cert-client-async/config-common" }
EOF
    fi
}
