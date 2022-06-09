
# kirkstone:
SRCREV_FORMAT .= "_iot-identity-service"
SRCREV_iot-identity-service = "6af42eefc84351ec7af510213561a40948ed9045"
SRCREV_FORMAT .= "_azure-iot-sdk"
SRCREV_azure-iot-sdk = "21c4d345093ad85318d2efe00a4aac33ebb1b950"
SRCREV_FORMAT .= "_azure-iot-sdk-sys"
SRCREV_azure-iot-sdk-sys = "f2c05d51392d86a85f6d4115e7faa8d7ea642ec8"
SRCREV_FORMAT .= "_eis-utils"
SRCREV_eis-utils = "aca6c68ca99764d638ac34638e5fe839f2064f03"
SRCREV_FORMAT .= "_sd-notify"
SRCREV_sd-notify = "c36f0bf43e154452fb97ab7da42db14fcd2571a3"

do_configure:append() {
    # patch paths to iot-identity-service services in eis-utils
    # workaround for yocto dunfell branch. it is expected that in yocto kirkstone this patch can be removed.

    sed -i -e 's/azure-iot-sdk =.*/azure-iot-sdk = { path = \"..\/azure-iot-sdk\", features = ["module_client"] }/' \
           -e 's/sd-notify =.*/sd-notify = { path = \"..\/sd-notify\", optional = true }/' ${S}/Cargo.toml

    sed -i -e 's/azure-iot-sdk-sys =.*/azure-iot-sdk-sys = { path = \"..\/azure-iot-sdk-sys\", default-features = false }/' \
           -e 's/eis-utils =.*/eis-utils = { path = \"..\/eis-utils\", optional = true }/' ${WORKDIR}/azure-iot-sdk/Cargo.toml

    sed -i -e 's/aziot-identity-client-async =.*/aziot-identity-client-async = { path = \"..\/iot-identity-service\/identity\/aziot-identity-client-async\" }/' \
           -e 's/aziot-identity-common =.*/aziot-identity-common = { path = \"..\/iot-identity-service\/identity\/aziot-identity-common\" }/' \
           -e 's/aziot-identityd-config =.*/aziot-identityd-config = { path = \"..\/iot-identity-service\/identity\/aziot-identityd-config\" }/' \
           -e 's/aziot-identity-common-http =.*/aziot-identity-common-http = { path = \"..\/iot-identity-service\/identity\/aziot-identity-common-http\" }/' \
           -e 's/aziot-keyd-config =.*/aziot-keyd-config = { path = \"..\/iot-identity-service\/key\/aziot-keyd-config\" }/' \
           -e 's/aziot-key-client-async =.*/aziot-key-client-async = { path = \"..\/iot-identity-service\/key\/aziot-key-client-async\" }/' \
           -e 's/aziot-key-common =.*/aziot-key-common = { path = \"..\/iot-identity-service\/key\/aziot-key-common\" }/' \
           -e 's/aziot-key-common-http =.*/aziot-key-common-http = { path = \"..\/iot-identity-service\/key\/aziot-key-common-http\" }/' \
           -e 's/aziot-cert-client-async =.*/aziot-cert-client-async = { path = \"..\/iot-identity-service\/cert\/aziot-cert-client-async\" }/' \
           -e 's/aziot-cert-common =.*/aziot-cert-common = { path = \"..\/iot-identity-service\/cert\/aziot-cert-common\" }/' \
           -e 's/aziot-certd-config =.*/aziot-certd-config = { path = \"..\/iot-identity-service\/cert\/aziot-certd-config\" }/' \
           -e 's/aziot-cert-common-http =.*/aziot-cert-common-http = { path = \"..\/iot-identity-service\/cert\/aziot-cert-common-http\" }/' \
           -e 's/http-common =.*/http-common = { path = \"..\/iot-identity-service\/http-common\" }/' ${WORKDIR}/eis-utils/Cargo.toml
}
