FILESEXTRAPATHS:prepend := "${LAYERDIR_ics_dm}/files:"

SRC_URI += "\
  file://iot-identity-service-keyd.template.toml \
  file://iot-identity-service-identityd.template.toml \
"

# overwrite LICENSE and LIC_FILES_CHKSUM from cargo-bitbake generated recipe
LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://LICENSE-APACHE;md5=650e893673eb59696f3d4ee64f6d2357 \
    file://LICENSE-MIT;md5=afb814368d9110052a22e0da67f027d3 \
"

DEPENDS += "\
    azure-iot-sdk-c\
"
RDEPENDS:${PN} += "\
    ca-certificates\
    iot-identity-service\
"
inherit aziot systemd

# we can not set locked, because we currently patch Cargo.toml.
# as soon as we publish the repo and can access it via https,
# we can enable locked builds.
# since we build offline anyway, it's questionable if we benefit from it
# anyway.
#CARGO_BUILD_FLAGS += "--locked"

do_configure:append() {

    # patch paths to enable offline builds. cargo_common.bbclass can not handle
    # git dependencies with ssh links well.

    sed -i -e 's/azure-iot-sdk =.*/azure-iot-sdk = { path = \"..\/azure-iot-sdk\", default-features = false }/' \
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

do_compile:prepend() {
    export LLVM_CONFIG_PATH="${STAGING_LIBDIR_NATIVE}/llvm-rust/bin/llvm-config"
    export BINDGEN_EXTRA_CLANG_ARGS="${TUNE_CCARGS}"

    export LIB_PATH_AZURESDK=${STAGING_DIR_TARGET}/usr/
    export LIB_PATH_UUID=${STAGING_DIR_TARGET}/usr/
    export LIB_PATH_OPENSSL=${STAGING_DIR_TARGET}/usr/
    export LIB_PATH_CURL=${STAGING_DIR_TARGET}/usr/
}

do_install:append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/systemd/iot-client-template-rs.service ${D}${systemd_system_unitdir}/iot-client-template-rs.service
    install -m 0644 ${S}/systemd/iot-client-template-rs.timer ${D}${systemd_system_unitdir}/iot-client-template-rs.timer

    # allow iot-client-template-rs access to device_id secret created by manual provisioning
    install -m 0600 -o aziotks -g aziotks ${WORKDIR}/iot-identity-service-keyd.template.toml ${D}${sysconfdir}/aziot/keyd/config.d/iot-client-template-rs.toml

    # allow iot-client-template-rs provisioning via module identity
    install -m 0600 -o aziotid -g aziotid ${WORKDIR}/iot-identity-service-identityd.template.toml ${D}${sysconfdir}/aziot/identityd/config.d/iot-client-template-rs.toml
}

pkg_postinst:${PN}() {
    sed -i "s/@@UID@@/$(id -u iot-client-rs)/"                                           $D${sysconfdir}/aziot/keyd/config.d/iot-client-template-rs.toml
    sed -i -e "s/@@UID@@/$(id -u iot-client-rs)/" -e "s/@@NAME@@/iot-client-template-rs/"  $D${sysconfdir}/aziot/identityd/config.d/iot-client-template-rs.toml
}

SYSTEMD_SERVICE:${PN} = "iot-client-template-rs.service iot-client-template-rs.timer"

GROUPADD_PARAM:${PN} += "-r iot-client-rs;"
USERADD_PARAM:${PN} += "--no-create-home -r -s /bin/false -G aziotcs,aziotid,aziotks -g iot-client-rs iot-client-rs;"
