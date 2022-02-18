FILESEXTRAPATHS:prepend := "${LAYERDIR_ics_dm}/files:"

SRC_URI += "\
  file://iot-identity-service-keyd.template.toml \
  file://iot-identity-service-identityd.template.toml \
  file://rust_1.54.patch;patchdir=${WORKDIR} \
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
    export LIB_PATH_EISUTILS=${STAGING_DIR_TARGET}/usr/
    export LIB_PATH_UUID=${STAGING_DIR_TARGET}/usr/
    export LIB_PATH_OPENSSL=${STAGING_DIR_TARGET}/usr/
    export LIB_PATH_CURL=${STAGING_DIR_TARGET}/usr/
}

do_install_append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/systemd/iot-module-template-rs.service ${D}${systemd_system_unitdir}/iot-module-template-rs.service
    install -m 0644 ${S}/systemd/iot-module-template-rs.timer ${D}${systemd_system_unitdir}/iot-module-template-rs.timer

    # allow iot-module-template-rs access to device_id secret created by manual provisioning
    install -m 0600 -o aziotks -g aziotks ${WORKDIR}/iot-identity-service-keyd.template.toml ${D}${sysconfdir}/aziot/keyd/config.d/iot-module-template-rs.toml

    # allow iot-module-template-rs provisioning via module identity
    install -m 0600 -o aziotid -g aziotid ${WORKDIR}/iot-identity-service-identityd.template.toml ${D}${sysconfdir}/aziot/identityd/config.d/iot-module-template-rs.toml
}

pkg_postinst_${PN}() {
    sed -i "s/@@UID@@/$(id -u iotmodule-rs)/"                                           $D${sysconfdir}/aziot/keyd/config.d/iot-module-template-rs.toml
    sed -i -e "s/@@UID@@/$(id -u iotmodule-rs)/" -e "s/@@NAME@@/ics-dm-iot-module-rs/"  $D${sysconfdir}/aziot/identityd/config.d/iot-module-template-rs.toml
}

SYSTEMD_SERVICE_${PN} = "iot-module-template-rs.service iot-module-template-rs.timer"

GROUPADD_PARAM_${PN} += "-r iotmodule-rs;"
USERADD_PARAM_${PN} += "--no-create-home -r -s /bin/false -G aziotcs,aziotid,aziotks -g iotmodule-rs iotmodule-rs;"
