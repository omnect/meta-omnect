# unfortunately can not be set as do_configure:append - it clashes with the cargo_common patch mechanism then
do_compile:prepend() {
    # instead of sed, i wanted to use toml-cli, but it can not escape the values correctly
    sed -i \
        -e 's#"${WORKDIR}/aziot-cert-client-async"#"${WORKDIR}/aziot-cert-client-async/cert/aziot-cert-client-async"#' \
        -e 's#"${WORKDIR}/aziot-cert-common"#"${WORKDIR}/aziot-cert-client-async/cert/aziot-cert-common"#' \
        -e 's#"${WORKDIR}/aziot-cert-common-http"#"${WORKDIR}/aziot-cert-client-async/cert/aziot-cert-common-http"#' \
        -e 's#"${WORKDIR}/aziot-certd-config"#"${WORKDIR}/aziot-cert-client-async/cert/aziot-certd-config"#' \
        -e 's#"${WORKDIR}/aziot-identity-client-async"#"${WORKDIR}/aziot-cert-client-async/identity/aziot-identity-client-async"#' \
        -e 's#"${WORKDIR}/aziot-identity-common"#"${WORKDIR}/aziot-cert-client-async/identity/aziot-identity-common"#' \
        -e 's#"${WORKDIR}/aziot-identity-common-http"#"${WORKDIR}/aziot-cert-client-async/identity/aziot-identity-common-http"#' \
        -e 's#"${WORKDIR}/aziot-identityd-config"#"${WORKDIR}/aziot-cert-client-async/identity/aziot-identityd-config"#' \
        -e 's#"${WORKDIR}/aziot-key-client"#"${WORKDIR}/aziot-cert-client-async/key/aziot-key-client"#' \
        -e 's#"${WORKDIR}/aziot-key-client-async"#"${WORKDIR}/aziot-cert-client-async/key/aziot-key-client-async"#' \
        -e 's#"${WORKDIR}/aziot-key-common"#"${WORKDIR}/aziot-cert-client-async/key/aziot-key-common"#' \
        -e 's#"${WORKDIR}/aziot-key-common-http"#"${WORKDIR}/aziot-cert-client-async/key/aziot-key-common-http"#' \
        -e 's#"${WORKDIR}/aziot-key-openssl-engine"#"${WORKDIR}/aziot-cert-client-async/key/aziot-key-openssl-engine"#' \
        -e 's#"${WORKDIR}/aziot-keyd-config"#"${WORKDIR}/aziot-cert-client-async/key/aziot-keyd-config"#' \
        -e 's#"${WORKDIR}/aziot-keys-common"#"${WORKDIR}/aziot-cert-client-async/key/aziot-keys-common"#' \
        -e 's#"${WORKDIR}/aziot-tpmd-config"#"${WORKDIR}/aziot-cert-client-async/tpm/aziot-tpmd-config"#' \
        -e 's#"${WORKDIR}/aziotctl-common"#"${WORKDIR}/aziot-cert-client-async/aziotctl/aziotctl-common"#' \
        -e 's#"${WORKDIR}/cert-renewal"#"${WORKDIR}/aziot-cert-client-async/cert/cert-renewal"#' \
        -e 's#"${WORKDIR}/config-common"#"${WORKDIR}/aziot-cert-client-async/config-common"#' \
        -e 's#"${WORKDIR}/http-common"#"${WORKDIR}/aziot-cert-client-async/http-common"#' \
        -e 's#"${WORKDIR}/logger"#"${WORKDIR}/aziot-cert-client-async/logger"#' \
        -e 's#"${WORKDIR}/openssl-build"#"${WORKDIR}/aziot-cert-client-async/openssl-build"#' \
        -e 's#"${WORKDIR}/openssl-sys2"#"${WORKDIR}/aziot-cert-client-async/openssl-sys2"#' \
        -e 's#"${WORKDIR}/openssl2"#"${WORKDIR}/aziot-cert-client-async/openssl2"#' \
        -e 's#"${WORKDIR}/pkcs11-sys"#"${WORKDIR}/aziot-cert-client-async/pkcs11/pkcs11-sys"#' \
        -e 's#"${WORKDIR}/pkcs11"#"${WORKDIR}/aziot-cert-client-async/pkcs11/pkcs11"#' \
        -e 's#"${WORKDIR}/test-common"#"${WORKDIR}/aziot-cert-client-async/test-common"#' \
        ${WORKDIR}/cargo_home/config
}
