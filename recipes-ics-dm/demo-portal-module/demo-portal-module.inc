FILESEXTRAPATHS:prepend := "${LAYERDIR_ics_dm}/files:"

SRC_URI += "\
  file://iot-identity-service-keyd.template.toml \
  file://iot-identity-service-identityd.template.toml \
"

# overwrite LICENSE and LIC_FILES_CHKSUM from cargo-bitbake generated recipe
LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://LICENSE-APACHE;md5=650e893673eb59696f3d4ee64f6d2357 \
    file://LICENSE-MIT;md5=6340606a960b1965e521043f21f8d1bb \
"

DEPENDS += "\
    azure-iot-sdk-c\
"
RDEPENDS_${PN} += "\
    ca-certificates\
    iot-identity-service\
"
inherit aziot systemd

do_compile_prepend() {
    # - for now we use git to fetch the repo instead of cargo itself
    #   (cargo fetcher can not handle git repos via ssh)
    # - @ToDo rm as soon the repo is public
    export CARGO_NET_GIT_FETCH_WITH_CLI=true

    export LLVM_CONFIG_PATH="${STAGING_LIBDIR_NATIVE}/llvm-rust/bin/llvm-config"
    export BINDGEN_EXTRA_CLANG_ARGS="${TUNE_CCARGS}"

    export LIB_PATH_AZURESDK=${STAGING_DIR_TARGET}/usr/
    export LIB_PATH_UUID=${STAGING_DIR_TARGET}/usr/
    export LIB_PATH_OPENSSL=${STAGING_DIR_TARGET}/usr/
    export LIB_PATH_CURL=${STAGING_DIR_TARGET}/usr/

    sed -i '/edition = '\"2021\"'/c\edition = '\"2018\"'' ${S}/Cargo.toml
    sed -i '/azure-iot-sdk =/c\azure-iot-sdk = { path = '\"../azure-iot-sdk\"' }' ${S}/Cargo.toml
    sed -i '/sd-notify =/c\sd-notify = { path = '\"../sd-notify\"' , optional = true }' ${S}/Cargo.toml

    sed -i '/edition = '\"2021\"'/c\edition = '\"2018\"'' ${WORKDIR}/sd-notify/Cargo.toml

    sed -i '/edition = '\"2021\"'/c\edition = '\"2018\"'' ${WORKDIR}/azure-iot-sdk-sys/Cargo.toml

    sed -i '/edition = '\"2021\"'/c\edition = '\"2018\"'' ${WORKDIR}/azure-iot-sdk/Cargo.toml
    sed -i '/azure-iot-sdk-sys =/c\azure-iot-sdk-sys = { path = '\"../azure-iot-sdk-sys\"' }' ${WORKDIR}/azure-iot-sdk/Cargo.toml
    sed -i '/eis-utils =/c\eis-utils = { path = '\"../eis-utils\"' }' ${WORKDIR}/azure-iot-sdk/Cargo.toml

    sed -i '/edition = '\"2021\"'/c\edition = '\"2018\"'' ${WORKDIR}/eis-utils/Cargo.toml

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

    find ${WORKDIR}/iot-identity-service -name Cargo.toml -type f -exec sed -i '/edition = '\"2021\"'/c\edition = '\"2018\"'' {} \;
}

do_install_append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/systemd/demo-portal-module.service ${D}${systemd_system_unitdir}/demo-portal-module.service
    install -m 0644 ${S}/systemd/demo-portal-module.timer ${D}${systemd_system_unitdir}/demo-portal-module.timer
    install -m 0644 ${S}/systemd/demo-portal-factory-reset.service ${D}${systemd_system_unitdir}/demo-portal-factory-reset.service
    install -m 0644 ${S}/systemd/demo-portal-factory-reset.path ${D}${systemd_system_unitdir}/demo-portal-factory-reset.path
    install -m 755 ${S}/script/factory_reset.sh ${D}${bindir}/

    # allow demo-portal-module access to device_id secret created by manual provisioning
    install -m 0600 -o aziotks -g aziotks ${WORKDIR}/iot-identity-service-keyd.template.toml ${D}${sysconfdir}/aziot/keyd/config.d/demo-portal-module.toml

    # allow demo-portal-module provisioning via module identity
    install -m 0600 -o aziotid -g aziotid ${WORKDIR}/iot-identity-service-identityd.template.toml ${D}${sysconfdir}/aziot/identityd/config.d/demo-portal-module.toml
}

pkg_postinst_${PN}() {
    sed -i "s/@@UID@@/$(id -u demo-portal)/"                                           $D${sysconfdir}/aziot/keyd/config.d/demo-portal-module.toml
    sed -i -e "s/@@UID@@/$(id -u demo-portal)/" -e "s/@@NAME@@/demo-portal-module/"    $D${sysconfdir}/aziot/identityd/config.d/demo-portal-module.toml
}

SYSTEMD_SERVICE_${PN} = "demo-portal-module.service demo-portal-module.timer demo-portal-factory-reset.path"

FILES:${PN} += "\
    ${systemd_system_unitdir}/demo-portal-factory-reset.service \
    ${bindir}/factory_reset.sh \
"

GROUPADD_PARAM:${PN} += " \
  -r demo-portal; \
  -r factory_reset; \
  -r disk; \
"

USERADD_PARAM:${PN} += "--no-create-home -r -s /bin/false -G aziotcs,aziotid,aziotks,factory_reset,disk -g demo-portal demo-portal;"
