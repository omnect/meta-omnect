FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:${LAYERDIR_ics_dm}/files:"
inherit aziot cargo systemd

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=4f9c2c296f77b3096b6c11a16fa7c66e"

SRC_URI = "gitsm://git@github.com/Azure/iot-identity-service.git;protocol=ssh;nobranch=1;branch=release/1.3;tag=1.3.0"
SRC_URI += " \
    file://iot-identity-service-certd.template.toml \
    file://tpm-compile-fix.patch \
"

S = "${WORKDIR}/git"
B = "${S}"

DEPENDS += "openssl rust-bindgen-native rust-cbindgen-native"

CARGO_DISABLE_BITBAKE_VENDORING = "1"

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
    sed -i -e 's/CARGO_TARGET = \(.*\)/CARGO_TARGET = ${TARGET_SYS}/g' ${S}/Makefile

    make default
}

do_install() {

    # tpmfiles.d
    install -d ${D}${libdir}/tmpfiles.d

    # binaries
    install -d -m 0755  ${D}${bindir}
    install -m 0755     ${B}/target/${TARGET_SYS}/release/aziotctl ${D}${bindir}

    install -d -m 0750 -g aziot ${D}${libexecdir}/aziot-identity-service
    install -m 0750 -g aziot ${B}/target/${TARGET_SYS}/release/aziotd ${D}${libexecdir}/aziot-identity-service

    lnr  ${D}${libexecdir}/aziot-identity-service/aziotd ${D}${libexecdir}/aziot-identity-service/aziot-certd
    lnr  ${D}${libexecdir}/aziot-identity-service/aziotd ${D}${libexecdir}/aziot-identity-service/aziot-identityd
    lnr  ${D}${libexecdir}/aziot-identity-service/aziotd ${D}${libexecdir}/aziot-identity-service/aziot-keyd

    if ${@bb.utils.contains('MACHINE_FEATURES', 'tpm2', 'true', 'false', d)}; then
        ln -rs ${D}${libexecdir}/aziot-identity-service/aziotd ${D}${libexecdir}/aziot-identity-service/aziot-tpmd
    fi

    # libaziot-keys
    install -d -m 0755  ${D}${libdir}
    install -m 0644 -D  ${B}/target/${TARGET_SYS}/release/libaziot_keys.so ${D}${libdir}

    # default configs and config directories
    echo "z ${sysconfdir}/aziot 0775 root aziot -" >> ${D}${libdir}/tmpfiles.d/iot-identity-service.conf
    echo "z ${sysconfdir}/aziot/config.toml 0664 root aziot -" >> ${D}${libdir}/tmpfiles.d/iot-identity-service.conf
    echo "z ${sysconfdir}/aziot/certd/config.d 0700 aziotcs aziotcs -"  >> ${D}${libdir}/tmpfiles.d/iot-identity-service.conf
    echo "z ${sysconfdir}/aziot/certd/config.d/* 0600 aziotcs aziotcs -"  >> ${D}${libdir}/tmpfiles.d/iot-identity-service.conf
    install -m 0640     ${S}/cert/aziot-certd/config/unix/default.toml ${D}${sysconfdir}/aziot/certd/config.toml.default

    echo "z ${sysconfdir}/aziot/identityd/config.d 0700 aziotid aziotid -"  >> ${D}${libdir}/tmpfiles.d/iot-identity-service.conf
    echo "z ${sysconfdir}/aziot/identityd/config.d/* 0600 aziotid aziotid -"  >> ${D}${libdir}/tmpfiles.d/iot-identity-service.conf
    install -m 0640     ${S}/identity/aziot-identityd/config/unix/default.toml ${D}${sysconfdir}/aziot/identityd/config.toml.default

    echo "z ${sysconfdir}/aziot/keyd/config.d 0700 aziotks aziotks -"  >> ${D}${libdir}/tmpfiles.d/iot-identity-service.conf
    echo "z ${sysconfdir}/aziot/keyd/config.d/* 0600 aziotks aziotks -"  >> ${D}${libdir}/tmpfiles.d/iot-identity-service.conf
    install -m 0644     ${S}/key/aziot-keyd/config/unix/default.toml ${D}${sysconfdir}/aziot/keyd/config.toml.default
    echo "d /mnt/data/var/secrets/aziot/keyd 0700 aziotks aziotks -"  >> ${D}${libdir}/tmpfiles.d/iot-identity-service.conf
    install -d ${D}/var
    lnr  ${D}/mnt/data/var/secrets ${D}/var/secrets

    install -d -m 0750 -g aziottpm ${D}${sysconfdir}/aziot/tpmd
    install -d -m 0700 -o aziottpm -g aziottpm ${D}${sysconfdir}/aziot/tpmd/config.d
    echo "z ${sysconfdir}/aziot/tpmd/config.d 0700 aziottpm aziottpm -"  >> ${D}${libdir}/tmpfiles.d/iot-identity-service.conf
    echo "z ${sysconfdir}/aziot/tpmd/config.d/* 0600 aziottpm aziottpm -"  >> ${D}${libdir}/tmpfiles.d/iot-identity-service.conf
    install -m 0640     ${S}/tpm/aziot-tpmd/config/unix/default.toml ${D}${sysconfdir}/aziot/tpmd/config.toml.default

    install -m 0640     ${S}/aziotctl/config/unix/template.toml ${D}${sysconfdir}/aziot/config.toml.template

    # home directories
    install -d -m 0700  ${D}${localstatedir}/lib/aziot/certd
    echo "d ${localstatedir}/lib/aziot/certd 0700 aziotcs aziotcs -"  >> ${D}${libdir}/tmpfiles.d/iot-identity-service.conf
    install -d -m 0700  ${D}${localstatedir}/lib/aziot/identityd
    echo "d ${localstatedir}/lib/aziot/identityd 0700 aziotid aziotid -"  >> ${D}${libdir}/tmpfiles.d/iot-identity-service.conf
    install -d -m 0700  ${D}${localstatedir}/lib/aziot/keyd
    echo "d ${localstatedir}/lib/aziot/keyd 0700 aziotks aziotks -"  >> ${D}${libdir}/tmpfiles.d/iot-identity-service.conf
    install -d -m 0700  ${D}${localstatedir}/lib/aziot/tpmd
    echo "d ${localstatedir}/lib/aziot/tpmd 0700 aziottpm aziottpm -"  >> ${D}${libdir}/tmpfiles.d/iot-identity-service.conf

    # systemd services and sockets
    install -d -m 0755  ${D}${systemd_system_unitdir}
    install -m 0644     ${S}/cert/aziot-certd/aziot-certd.service ${D}${systemd_system_unitdir}/aziot-certd.service
    sed -i 's/^After=\(.*\)$/After=\1 systemd-tmpfiles-setup.service/' ${D}${systemd_system_unitdir}/aziot-certd.service
    sed -i 's#^After=\(.*\)$#After=\1\nConditionPathExists=/etc/aziot/config.toml\nConditionPathExists=/etc/aziot/identityd/config.d/00-super.toml#' ${D}${systemd_system_unitdir}/aziot-certd.service
    install -m 0644     ${S}/cert/aziot-certd/aziot-certd.socket ${D}${systemd_system_unitdir}/aziot-certd.socket
    # enable identity service to create cert "device-id" (e.g. for x509 dps provisioning)
    install -m 0600 -o aziotcs -g aziotcs ${WORKDIR}/iot-identity-service-certd.template.toml ${D}${sysconfdir}/aziot/certd/config.d/aziotid.toml

    install -m 0644     ${S}/identity/aziot-identityd/aziot-identityd.service ${D}${systemd_system_unitdir}/aziot-identityd.service
    sed -i 's/^After=\(.*\)$/After=\1 systemd-tmpfiles-setup.service/' ${D}${systemd_system_unitdir}/aziot-identityd.service
    sed -i 's#^After=\(.*\)$#After=\1\nConditionPathExists=/etc/aziot/config.toml\nConditionPathExists=/etc/aziot/identityd/config.d/00-super.toml#' ${D}${systemd_system_unitdir}/aziot-identityd.service
    install -m 0644     ${S}/identity/aziot-identityd/aziot-identityd.socket ${D}${systemd_system_unitdir}/aziot-identityd.socket

    install -m 0644     ${S}/key/aziot-keyd/aziot-keyd.service ${D}${systemd_system_unitdir}/aziot-keyd.service
    sed -i 's/^After=\(.*\)$/After=\1 systemd-tmpfiles-setup.service/' ${D}${systemd_system_unitdir}/aziot-keyd.service
    sed -i 's#^After=\(.*\)$#After=\1\nConditionPathExists=/etc/aziot/config.toml\nConditionPathExists=/etc/aziot/identityd/config.d/00-super.toml#' ${D}${systemd_system_unitdir}/aziot-keyd.service
    install -m 0644     ${S}/key/aziot-keyd/aziot-keyd.socket ${D}${systemd_system_unitdir}/aziot-keyd.socket

    if ${@bb.utils.contains('MACHINE_FEATURES', 'tpm2', 'true', 'false', d)}; then
        install -m 0644     ${S}/tpm/aziot-tpmd/aziot-tpmd.service ${D}${systemd_system_unitdir}/aziot-tpmd.service
        sed -i 's/^After=\(.*\)$/After=\1 systemd-tmpfiles-setup.service/' ${D}${systemd_system_unitdir}/aziot-tpmd.service
        sed -i 's#^After=\(.*\)$#After=\1\nConditionPathExists=/etc/aziot/config.toml\nConditionPathExists=/etc/aziot/identityd/config.d/00-super.toml#' ${D}${systemd_system_unitdir}/aziot-tpmd.service
        install -m 0644     ${S}/tpm/aziot-tpmd/aziot-tpmd.socket ${D}${systemd_system_unitdir}/aziot-tpmd.socket
    fi

    # libaziot-key-openssl-engine-shared
    install -d -m 0755  ${D}${libdir}/engines-1.1
    install -m 0644     ${B}/target/${TARGET_SYS}/release/libaziot_key_openssl_engine_shared.so ${D}${libdir}/engines-1.1/aziot_keys.so

    # devel
    install -d -m 0755  ${D}${includedir}/aziot-identity-service
    install -m 0644     ${S}/key/aziot-keys/aziot-keys.h ${D}${includedir}/aziot-identity-service/aziot-keys.h

    # run after time-sync.target
    sed -i 's/^After=\(.*\)$/After=\1 time-sync.target/' ${D}${systemd_system_unitdir}/aziot-identityd.service
}

pkg_postinst:${PN}() {
  sed -i "s/@@UID@@/$(id -u aziotid)/" $D${sysconfdir}/aziot/certd/config.d/aziotid.toml
}

FILES:${PN} += " \
    ${libdir}/engines-1.1/aziot_keys.so \
    ${libdir}/libaziot_keys.so \
    ${libdir}/tmpfiles.d/iot-identity-service.conf \
"

FILES:${PN}-dev = "${includedir}/aziot-identity-service/aziot-keys.h"

SYSTEMD_SERVICE:${PN} = " \
    aziot-certd.service \
    aziot-certd.socket \
    aziot-identityd.service \
    aziot-identityd.socket \
    aziot-keyd.service \
    aziot-keyd.socket \
"
SYSTEMD_SERVICE:${PN}:append = "${@bb.utils.contains('MACHINE_FEATURES', 'tpm2', ' aziot-tpmd.service aziot-tpmd.socket', '', d)}"
