FILESEXTRAPATHS_prepend := "${THISDIR}/../../files:"

SRC_URI += "\
  file://iot-identity-service-keyd.template.toml \
  file://iot-identity-service-identityd.template.toml \
"

DEPENDS += "\
    azure-iot-sdk-c\
    libeis-utils\
"
RDEPENDS_${PN} += "\
    ca-certificates\
    iot-identity-service\
"
inherit aziot systemd

do_compile_prepend() {
    # - it seems cargo wants at least to verify that there are no changes
    #   in the remote repo in regard to CARGO_HOME
    # - for now we use git to fetch the repo instead of cargo itself
    # - @ToDo patch cargo.toml file so that it doesnt see a remote ???
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
    install -m 0644 ${S}/systemd/ics-dm-iot-module-rs.service ${D}${systemd_system_unitdir}

    # allow ics-dm-iot-module-rs access to device_id secret created by manual provisioning
    install -m 0600 -o aziotks -g aziotks ${WORKDIR}/iot-identity-service-keyd.template.toml ${D}${sysconfdir}/aziot/keyd/config.d/ics-dm-iot-module-rs.toml

    # allow ics-dm-iot-module-rs provisioning via module identity
    install -m 0600 -o aziotid -g aziotid ${WORKDIR}/iot-identity-service-identityd.template.toml ${D}${sysconfdir}/aziot/identityd/config.d/ics-dm-iot-module-rs.toml
}

pkg_postinst_${PN}() {
    sed -i "s/@@UID@@/$(id -u iotmodule-rs)/" $D${sysconfdir}/aziot/keyd/config.d/ics-dm-iot-module-rs.toml
    sed -i -e "s/@@UID@@/$(id -u iotmodule-rs)/" -e "s/@@NAME@@/ics-dm-iot-module-rs/" $D${sysconfdir}/aziot/identityd/config.d/ics-dm-iot-module-rs.toml
}

SYSTEMD_SERVICE_${PN} = "ics-dm-iot-module-rs.service"

GROUPADD_PARAM_${PN} += "-r iotmodule-rs;"
USERADD_PARAM_${PN} += "--no-create-home -r -s /bin/false -G aziotcs,aziotid,aziotks -g iotmodule-rs iotmodule-rs;"
