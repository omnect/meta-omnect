# unfortunately can not be set as do_configure:append - it clashes with the cargo_common patch mechanism then
do_compile:prepend() {
    # instead of sed, i wanted to use toml-cli, but it can not escape the values correctly
    sed -i \
        -e 's#"${UNPACKDIR}/aziot-cert-client-async"#"${UNPACKDIR}/aziot-cert-client-async/cert/aziot-cert-client-async"#' \
        -e 's#"${UNPACKDIR}/aziot-cert-common"#"${UNPACKDIR}/aziot-cert-client-async/cert/aziot-cert-common"#' \
        -e 's#"${UNPACKDIR}/aziot-cert-common-http"#"${UNPACKDIR}/aziot-cert-client-async/cert/aziot-cert-common-http"#' \
        -e 's#"${UNPACKDIR}/aziot-certd-config"#"${UNPACKDIR}/aziot-cert-client-async/cert/aziot-certd-config"#' \
        -e 's#"${UNPACKDIR}/aziot-identity-client-async"#"${UNPACKDIR}/aziot-cert-client-async/identity/aziot-identity-client-async"#' \
        -e 's#"${UNPACKDIR}/aziot-identity-common"#"${UNPACKDIR}/aziot-cert-client-async/identity/aziot-identity-common"#' \
        -e 's#"${UNPACKDIR}/aziot-identity-common-http"#"${UNPACKDIR}/aziot-cert-client-async/identity/aziot-identity-common-http"#' \
        -e 's#"${UNPACKDIR}/aziot-identityd-config"#"${UNPACKDIR}/aziot-cert-client-async/identity/aziot-identityd-config"#' \
        -e 's#"${UNPACKDIR}/aziot-key-client"#"${UNPACKDIR}/aziot-cert-client-async/key/aziot-key-client"#' \
        -e 's#"${UNPACKDIR}/aziot-key-client-async"#"${UNPACKDIR}/aziot-cert-client-async/key/aziot-key-client-async"#' \
        -e 's#"${UNPACKDIR}/aziot-key-common"#"${UNPACKDIR}/aziot-cert-client-async/key/aziot-key-common"#' \
        -e 's#"${UNPACKDIR}/aziot-key-common-http"#"${UNPACKDIR}/aziot-cert-client-async/key/aziot-key-common-http"#' \
        -e 's#"${UNPACKDIR}/aziot-key-openssl-engine"#"${UNPACKDIR}/aziot-cert-client-async/key/aziot-key-openssl-engine"#' \
        -e 's#"${UNPACKDIR}/aziot-keyd-config"#"${UNPACKDIR}/aziot-cert-client-async/key/aziot-keyd-config"#' \
        -e 's#"${UNPACKDIR}/aziot-keys-common"#"${UNPACKDIR}/aziot-cert-client-async/key/aziot-keys-common"#' \
        -e 's#"${UNPACKDIR}/aziot-tpmd-config"#"${UNPACKDIR}/aziot-cert-client-async/tpm/aziot-tpmd-config"#' \
        -e 's#"${UNPACKDIR}/aziotctl-common"#"${UNPACKDIR}/aziot-cert-client-async/aziotctl/aziotctl-common"#' \
        -e 's#"${UNPACKDIR}/cert-renewal"#"${UNPACKDIR}/aziot-cert-client-async/cert/cert-renewal"#' \
        -e 's#"${UNPACKDIR}/config-common"#"${UNPACKDIR}/aziot-cert-client-async/config-common"#' \
        -e 's#"${UNPACKDIR}/http-common"#"${UNPACKDIR}/aziot-cert-client-async/http-common"#' \
        -e 's#"${UNPACKDIR}/logger"#"${UNPACKDIR}/aziot-cert-client-async/logger"#' \
        -e 's#"${UNPACKDIR}/openssl-build"#"${UNPACKDIR}/aziot-cert-client-async/openssl-build"#' \
        -e 's#"${UNPACKDIR}/openssl-sys2"#"${UNPACKDIR}/aziot-cert-client-async/openssl-sys2"#' \
        -e 's#"${UNPACKDIR}/openssl2"#"${UNPACKDIR}/aziot-cert-client-async/openssl2"#' \
        -e 's#"${UNPACKDIR}/pkcs11-sys"#"${UNPACKDIR}/aziot-cert-client-async/pkcs11/pkcs11-sys"#' \
        -e 's#"${UNPACKDIR}/pkcs11"#"${UNPACKDIR}/aziot-cert-client-async/pkcs11/pkcs11"#' \
        -e 's#"${UNPACKDIR}/test-common"#"${UNPACKDIR}/aziot-cert-client-async/test-common"#' \
        ${UNPACKDIR}/cargo_home/config.toml
}
