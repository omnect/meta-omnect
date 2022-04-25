do_configure:append() {
    # Workaround for Yocto Dunfell Branch, we expect that in Yocto Kirkstone this patch can be removed
    sed -i '/edition = '\"2021\"'/c\edition = '\"2018\"'' ${S}/Cargo.toml
    sed -i '/edition = '\"2021\"'/c\edition = '\"2018\"'' ${WORKDIR}/sd-notify/Cargo.toml
    sed -i '/edition = '\"2021\"'/c\edition = '\"2018\"'' ${WORKDIR}/azure-iot-sdk-sys/Cargo.toml
    sed -i '/edition = '\"2021\"'/c\edition = '\"2018\"'' ${WORKDIR}/azure-iot-sdk/Cargo.toml
    sed -i '/edition = '\"2021\"'/c\edition = '\"2018\"'' ${WORKDIR}/eis-utils/Cargo.toml
    find ${WORKDIR}/iot-identity-service -name Cargo.toml -type f -exec sed -i '/edition = '\"2021\"'/c\edition = '\"2018\"'' {} \;

    # Workaround for Yocto Dunfell Branch, we expect that in Yocto Kirkstone this patch can be removed
    sed -i '/azure-iot-sdk =/c\azure-iot-sdk = { path = '\"../azure-iot-sdk\"' }' ${S}/Cargo.toml
    sed -i '/sd-notify =/c\sd-notify = { path = '\"../sd-notify\"' , optional = true }' ${S}/Cargo.toml
    sed -i '/azure-iot-sdk-sys =/c\azure-iot-sdk-sys = { path = '\"../azure-iot-sdk-sys\"' }' ${WORKDIR}/azure-iot-sdk/Cargo.toml
    sed -i '/eis-utils =/c\eis-utils = { path = '\"../eis-utils\"' }' ${WORKDIR}/azure-iot-sdk/Cargo.toml
    sed -i '/aziot-identity-client-async =/c\aziot-identity-client-async = { path = '\"../iot-identity-service/identity/aziot-identity-client-async\"' }' ${WORKDIR}/eis-utils/Cargo.toml
    sed -i '/aziot-identity-common =/c\aziot-identity-common = { path = '\"../iot-identity-service/identity/aziot-identity-common\"' }' ${WORKDIR}/eis-utils/Cargo.toml
    sed -i '/aziot-identityd-config =/c\aziot-identityd-config = { path = '\"../iot-identity-service/identity/aziot-identityd-config\"' }' ${WORKDIR}/eis-utils/Cargo.toml
    sed -i '/aziot-identity-common-http =/c\aziot-identity-common-http = { path = '\"../iot-identity-service/identity/aziot-identity-common-http\"' }' ${WORKDIR}/eis-utils/Cargo.toml
    sed -i '/aziot-keyd-config =/c\aziot-keyd-config = { path = '\"../iot-identity-service/key/aziot-keyd-config\"' }' ${WORKDIR}/eis-utils/Cargo.toml
    sed -i '/aziot-key-client-async =/c\aziot-key-client-async = { path = '\"../iot-identity-service/key/aziot-key-client-async\"' }' ${WORKDIR}/eis-utils/Cargo.toml
    sed -i '/aziot-key-common =/c\aziot-key-common = { path = '\"../iot-identity-service/key/aziot-key-common\"' }' ${WORKDIR}/eis-utils/Cargo.toml
    sed -i '/aziot-key-common-http =/c\aziot-key-common-http = { path = '\"../iot-identity-service/key/aziot-key-common-http\"' }' ${WORKDIR}/eis-utils/Cargo.toml
    sed -i '/aziot-cert-client-async =/c\aziot-cert-client-async = { path = '\"../iot-identity-service/cert/aziot-cert-client-async\"' }' ${WORKDIR}/eis-utils/Cargo.toml
    sed -i '/aziot-cert-common =/c\aziot-cert-common = { path = '\"../iot-identity-service/cert/aziot-cert-common\"' }' ${WORKDIR}/eis-utils/Cargo.toml
    sed -i '/aziot-certd-config =/c\aziot-certd-config = { path = '\"../iot-identity-service/cert/aziot-certd-config\"' }' ${WORKDIR}/eis-utils/Cargo.toml
    sed -i '/aziot-cert-common-http =/c\aziot-cert-common-http = { path = '\"../iot-identity-service/cert/aziot-cert-common-http\"' }' ${WORKDIR}/eis-utils/Cargo.toml
    sed -i '/http-common =/c\http-common = { path = '\"../iot-identity-service/http-common\"' }' ${WORKDIR}/eis-utils/Cargo.toml
}