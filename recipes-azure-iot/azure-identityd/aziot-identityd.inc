FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:${LAYERDIR_omnect}/files:"
inherit aziot systemd

# overwrite LICENSE amd LIC_FILES_CHKSUM from cargo-bitbake generated recipe
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=4f9c2c296f77b3096b6c11a16fa7c66e"


# patches
SRC_URI += " \
    file://apply_doesnt_restart_services.patch \
    file://send_sd_notify.patch \
"
# workspace
SRC_URI += " \
    file://aziot-identityd-precondition.service \
    file://iot-identity-service.conf \
    file://iot-identity-service-certd.template.toml \
"

# ToDo: remove this on next update; since `send_sd_notify.patch` will always
# patch the lock file anyway, we have no benefit with generating the
# recipe without the patched Cargo.toml
SRC_URI += "crate://crates.io/sd-notify/0.4.1"

CARGO_BUILD_FLAGS += "--offline"

B = "${S}"

DEPENDS = " \
    bindgen-native \
    cbindgen-native \
    openssl \
    pkgconfig-native \
    libtss2 \
"

RDEPENDS:${PN} = " \
    libtss2-tcti-device \
"

do_compile:prepend:raspberrypi3() {
    # Since setting BINDGEN_EXTRA_CLANG_ARGS does not help and CC + CCFLAGS look right, we
    # use a dirty fix to be able to compile tss-minimal with hard float.
    # BINDGEN_EXTRA_CLANG_ARGS:raspberrypi3 = "${TUNE_CCARGS} --sysroot ${STAGING_DIR_TARGET}"
    cd ${STAGING_DIR_TARGET}/usr/include/gnu
    ln -sf stubs-hard.h stubs-soft.h
    cd -
}

do_compile() {
    oe_cargo_fix_env
    export RUSTFLAGS="${RUSTFLAGS}"
    export RUST_TARGET_PATH="${RUST_TARGET_PATH}"

    # pkg specific exports
    export RELEASE="1"
    export LLVM_CONFIG_PATH="${STAGING_LIBDIR_NATIVE}/llvm-rust/bin/llvm-config"
    export PATH="${CARGO_HOME}/bin:${PATH}"
    export OPENSSL_DIR="${STAGING_EXECPREFIXDIR}"
    export FORCE_NO_UNITTEST="ON"

    sed -i 's/^RELEASE = 0$/RELEASE = 1/'       ${S}/Makefile
    sed -i -e 's/CARGO_TARGET = \(.*\)/CARGO_TARGET = ${RUST_TARGET_SYS}/g' ${S}/Makefile

    # we don't build tpm2-tss as part of this build
    rm -rf third-party/tpm2-tss

    make default
}

export USER_AZIOTID = "aziotid"
export USER_AZIOTCS = "aziotcs"
export USER_AZIOTKS = "aziotks"
export USER_AZIOTTPM = "aziottpm"
export SOCKET_DIR = "/run/aziot"

fill_placeholders() {
    local file="$1"
    sed -i -e 's|@user_aziotid@|${USER_AZIOTID}|' \
           -e 's|@user_aziotks@|${USER_AZIOTKS}|' \
           -e 's|@user_aziotcs@|${USER_AZIOTCS}|' \
           -e 's|@user_aziottpm@|${USER_AZIOTTPM}|' \
           -e 's|@socket_dir@|${SOCKET_DIR}|' \
           "$file"
}

do_install() {
    # tpmfiles.d
    install -d ${D}${libdir}/tmpfiles.d

    # binaries
    install -d -m 0755  ${D}${bindir}
    install -m 0755     ${B}/target/${CARGO_TARGET_SUBDIR}/aziotctl ${D}${bindir}

    install -d -m 0750 -g aziot ${D}${libexecdir}/aziot-identity-service
    install -m 0750 -g aziot ${B}/target/${CARGO_TARGET_SUBDIR}/aziotd ${D}${libexecdir}/aziot-identity-service

    ln -rs ${D}${libexecdir}/aziot-identity-service/aziotd ${D}${libexecdir}/aziot-identity-service/aziot-certd
    ln -rs ${D}${libexecdir}/aziot-identity-service/aziotd ${D}${libexecdir}/aziot-identity-service/aziot-identityd
    ln -rs ${D}${libexecdir}/aziot-identity-service/aziotd ${D}${libexecdir}/aziot-identity-service/aziot-keyd

    if ${@bb.utils.contains('MACHINE_FEATURES', 'tpm2', 'true', 'false', d)}; then
        ln -rs ${D}${libexecdir}/aziot-identity-service/aziotd ${D}${libexecdir}/aziot-identity-service/aziot-tpmd
    fi

    # libaziot-keys
    install -d -m 0755  ${D}${libdir}
    install -m 0644 -D  ${B}/target/${CARGO_TARGET_SUBDIR}/libaziot_keys.so ${D}${libdir}

    # default configs and config directories
    install -m 0644 -D  ${WORKDIR}/iot-identity-service.conf ${D}${libdir}/tmpfiles.d/iot-identity-service.conf
    install -m 0640     ${S}/cert/aziot-certd/config/unix/default.toml ${D}${sysconfdir}/aziot/certd/config.toml.default
    install -m 0640     ${S}/identity/aziot-identityd/config/unix/default.toml ${D}${sysconfdir}/aziot/identityd/config.toml.default
    install -m 0644     ${S}/key/aziot-keyd/config/unix/default.toml ${D}${sysconfdir}/aziot/keyd/config.toml.default
    install -d          ${D}/var
    ln -rs ${D}/mnt/data/var/secrets ${D}/var/secrets
    install -d -m 0750 -g aziottpm ${D}${sysconfdir}/aziot/tpmd
    install -d -m 0700 -o aziottpm -g aziottpm ${D}${sysconfdir}/aziot/tpmd/config.d
    install -m 0640     ${S}/tpm/aziot-tpmd/config/unix/default.toml ${D}${sysconfdir}/aziot/tpmd/config.toml.default
    install -m 0640     ${S}/aziotctl/config/unix/template.toml ${D}${sysconfdir}/aziot/config.toml.template

    # home directories
    install -d -m 0700  ${D}${localstatedir}/lib/aziot/certd
    install -d -m 0700  ${D}${localstatedir}/lib/aziot/identityd
    install -d -m 0700  ${D}${localstatedir}/lib/aziot/keyd
    install -d -m 0700  ${D}${localstatedir}/lib/aziot/tpmd

    # systemd services and sockets
    install -d -m 0755  ${D}${systemd_system_unitdir}
    install -m 0644     ${S}/cert/aziot-certd/aziot-certd.service.in ${D}${systemd_system_unitdir}/aziot-certd.service
    sed -i \
        -e 's/^After=\(.*\)$/After=\1 systemd-tmpfiles-setup.service time-sync.target/' \
        -e 's#^After=\(.*\)$#After=\1\nConditionPathExists=/etc/aziot/config.toml\nConditionPathExists=/etc/aziot/identityd/config.d/00-super.toml#' \
        -e 's#@libexecdir@#/usr/libexec#g' \
        -e '/Environment=\(.*\)$/d' \
	-e 's#^ExecStart=\(.*\)$#ExecStartPre=+-bash -c "/usr/sbin/omnect_service_log.sh start aziot-certd"\nExecStart=\1\nExecStopPost=+-/bin/sh -c "/usr/sbin/omnect_service_log.sh stop aziot-certd \\"$$SERVICE_RESULT\\" \\"$$EXIT_CODE\\" \\"$$EXIT_STATUS\\""#' \
        ${D}${systemd_system_unitdir}/aziot-certd.service
    install -m 0644     ${S}/cert/aziot-certd/aziot-certd.socket.in ${D}${systemd_system_unitdir}/aziot-certd.socket
    fill_placeholders ${D}${systemd_system_unitdir}/aziot-certd.service
    fill_placeholders ${D}${systemd_system_unitdir}/aziot-certd.socket

    # enable identity service to create cert "device-id" (e.g. for x509 dps provisioning)
    install -m 0600 -o aziotcs -g aziotcs ${WORKDIR}/iot-identity-service-certd.template.toml ${D}${sysconfdir}/aziot/certd/config.d/aziotid.toml

    install -m 0644     ${S}/identity/aziot-identityd/aziot-identityd.service.in ${D}${systemd_system_unitdir}/aziot-identityd.service
    sed -i \
        -e 's/^After=\(.*\)$/After=\1 systemd-tmpfiles-setup.service network-online.target time-sync.target/' \
        -e 's#^After=\(.*\)$#After=\1\nConditionPathExists=/etc/aziot/config.toml\nConditionPathExists=/etc/aziot/identityd/config.d/00-super.toml#' \
        -e 's#@libexecdir@#/usr/libexec#g' \
        -e '/Environment=\(.*\)$/d' \
	-e 's#^ExecStart=\(.*\)$#ExecStartPre=+-bash -c "/usr/sbin/omnect_service_log.sh start aziot-identityd"\nExecStart=\1\nExecStopPost=+-/bin/sh -c "/usr/sbin/omnect_service_log.sh stop aziot-identityd \\"$$SERVICE_RESULT\\" \\"$$EXIT_CODE\\" \\"$$EXIT_STATUS\\""#' \
        -e 's/^Requires=\(.*\)$/Requires=\1 network-online.target/' \
        ${D}${systemd_system_unitdir}/aziot-identityd.service
    install -m 0644     ${S}/identity/aziot-identityd/aziot-identityd.socket.in ${D}${systemd_system_unitdir}/aziot-identityd.socket
    fill_placeholders ${D}${systemd_system_unitdir}/aziot-identityd.service
    fill_placeholders ${D}${systemd_system_unitdir}/aziot-identityd.socket

    install -m 0644     ${S}/key/aziot-keyd/aziot-keyd.service.in ${D}${systemd_system_unitdir}/aziot-keyd.service
    sed -i \
        -e 's/^After=\(.*\)$/After=\1 systemd-tmpfiles-setup.service time-sync.target/' \
        -e 's#^After=\(.*\)$#After=\1\nConditionPathExists=/etc/aziot/config.toml\nConditionPathExists=/etc/aziot/identityd/config.d/00-super.toml#' \
        -e 's#@libexecdir@#/usr/libexec#g' \
        -e '/Environment=\(.*\)$/d' \
	-e 's#^ExecStart=\(.*\)$#ExecStartPre=+-bash -c "/usr/sbin/omnect_service_log.sh start aziot-keyd"\nExecStart=\1\nExecStopPost=+-/bin/sh -c "/usr/sbin/omnect_service_log.sh stop aziot-keyd \\"$$SERVICE_RESULT\\" \\"$$EXIT_CODE\\" \\"$$EXIT_STATUS\\""#' \
        ${D}${systemd_system_unitdir}/aziot-keyd.service
    install -m 0644     ${S}/key/aziot-keyd/aziot-keyd.socket.in ${D}${systemd_system_unitdir}/aziot-keyd.socket
    fill_placeholders ${D}${systemd_system_unitdir}/aziot-keyd.service
    fill_placeholders ${D}${systemd_system_unitdir}/aziot-keyd.socket

    if ${@bb.utils.contains('MACHINE_FEATURES', 'tpm2', 'true', 'false', d)}; then
        install -m 0644     ${S}/tpm/aziot-tpmd/aziot-tpmd.service.in ${D}${systemd_system_unitdir}/aziot-tpmd.service
        sed -i \
            -e 's/^After=\(.*\)$/After=\1 systemd-tmpfiles-setup.service dev-tpmrm0.device/' \
            -e 's#^After=\(.*\)$#After=\1\nConditionPathExists=/etc/aziot/config.toml\nConditionPathExists=/etc/aziot/identityd/config.d/00-super.toml\nConditionPathExists=/dev/tpmrm0#' \
            -e 's#@libexecdir@#/usr/libexec#g' \
            -e '/Environment=\(.*\)$/d' \
            -e 's#^ExecStart=\(.*\)$#ExecStartPre=+-bash -c "/usr/sbin/omnect_service_log.sh start aziot-tpmd"\nExecStart=\1\nExecStopPost=+-/bin/sh -c "/usr/sbin/omnect_service_log.sh stop aziot-tpmd \\"$$SERVICE_RESULT\\" \\"$$EXIT_CODE\\" \\"$$EXIT_STATUS\\""#' \
            ${D}${systemd_system_unitdir}/aziot-tpmd.service
        install -m 0644     ${S}/tpm/aziot-tpmd/aziot-tpmd.socket.in ${D}${systemd_system_unitdir}/aziot-tpmd.socket
        fill_placeholders ${D}${systemd_system_unitdir}/aziot-tpmd.service
        fill_placeholders ${D}${systemd_system_unitdir}/aziot-tpmd.socket
    fi

    # libaziot-key-openssl-engine-shared
    install -d -m 0755  ${D}${libdir}/engines-3
    install -m 0644     ${B}/target/${CARGO_TARGET_SUBDIR}/libaziot_key_openssl_engine_shared.so ${D}${libdir}/engines-3/aziot_keys.so

    # devel
    install -d -m 0755  ${D}${includedir}/aziot-identity-service
    install -m 0644     ${S}/key/aziot-keys/aziot-keys.h ${D}${includedir}/aziot-identity-service/aziot-keys.h

    # aziot-identityd-precondition.service handling
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aziot-identityd-precondition.service ${D}${systemd_system_unitdir}/aziot-identityd-precondition.service
    if ${@bb.utils.contains('DISTRO_FEATURES', 'iotedge', 'true', 'false', d)}; then
        sed -i "s/@@AZIOTCLI@@/iotedge/" ${D}${systemd_system_unitdir}/aziot-identityd-precondition.service
    else
        sed -i "s/@@AZIOTCLI@@/aziotctl/" ${D}${systemd_system_unitdir}/aziot-identityd-precondition.service
    fi
}

pkg_postinst:${PN}() {
    sed -i "s/@@UID@@/$(id -u aziotid)/" $D${sysconfdir}/aziot/certd/config.d/aziotid.toml
}

FILES:${PN} += " \
    ${libdir}/engines-3/aziot_keys.so \
    ${libdir}/libaziot_keys.so \
    ${libdir}/tmpfiles.d/iot-identity-service.conf \
"

FILES:${PN}-dev = "${includedir}/aziot-identity-service/aziot-keys.h"

SYSTEMD_SERVICE:${PN} = " \
    aziot-certd.service \
    aziot-certd.socket \
    aziot-identityd.service \
    aziot-identityd.socket \
    aziot-identityd-precondition.service \
    aziot-keyd.service \
    aziot-keyd.socket \
"
SYSTEMD_SERVICE:${PN}:append = "${@bb.utils.contains('MACHINE_FEATURES', 'tpm2', ' aziot-tpmd.service aziot-tpmd.socket', '', d)}"
