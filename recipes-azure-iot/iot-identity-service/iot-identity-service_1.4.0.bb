FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:${LAYERDIR_ics_dm}/files:${LAYERDIR_ics_dm}/files/iotedge-patches:"
inherit aziot cargo systemd

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=4f9c2c296f77b3096b6c11a16fa7c66e"

# attention iot-identity-service 1.4 used by iotedge 1.4 is not officially tagged yet. so we use
# the srcrev of latest release/1.4 HEAD
# SRC_URI = "git://git@github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;tag=1.4.0"
SRC_URI = "git://git@github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;rev=c281b76772f16d7389fd6b25872c2119e539eab8"

SRC_URI += " \
    file://iot-identity-service-certd.template.toml \
    file://ossl300_fix_incompatible_pointer_types.patch \
    file://ossl300_default_provider.patch \
    file://ossl300_openssl-errors.patch \
    file://ossl300_Cargo.lock.patch \
    file://iot-identity-service_PR_451.patch \
"

CARGO_BUILD_FLAGS += "--offline"

# the following was generated via cargo-bitbake in ${S}/identity/aziot-identityd
SRC_URI += " \
    crate://crates.io/addr2line/0.17.0 \
    crate://crates.io/adler/1.0.2 \
    crate://crates.io/aho-corasick/0.7.18 \
    crate://crates.io/ansi_term/0.12.1 \
    crate://crates.io/anyhow/1.0.60 \
    crate://crates.io/async-recursion/1.0.0 \
    crate://crates.io/async-trait/0.1.57 \
    crate://crates.io/atty/0.2.14 \
    crate://crates.io/autocfg/1.1.0 \
    crate://crates.io/backtrace/0.3.66 \
    crate://crates.io/base64/0.13.0 \
    crate://crates.io/bindgen/0.60.1 \
    crate://crates.io/bitflags/1.3.2 \
    crate://crates.io/block-buffer/0.10.2 \
    crate://crates.io/block-buffer/0.9.0 \
    crate://crates.io/bumpalo/3.10.0 \
    crate://crates.io/byte-unit/4.0.14 \
    crate://crates.io/bytes/1.2.1 \
    crate://crates.io/cc/1.0.73 \
    crate://crates.io/cexpr/0.6.0 \
    crate://crates.io/cfg-if/0.1.10 \
    crate://crates.io/cfg-if/1.0.0 \
    crate://crates.io/chrono/0.4.20 \
    crate://crates.io/clang-sys/1.3.3 \
    crate://crates.io/clap/2.34.0 \
    crate://crates.io/colored/2.0.0 \
    crate://crates.io/core-foundation-sys/0.8.3 \
    crate://crates.io/cpufeatures/0.2.2 \
    crate://crates.io/crossbeam-channel/0.5.6 \
    crate://crates.io/crossbeam-deque/0.8.2 \
    crate://crates.io/crossbeam-epoch/0.9.10 \
    crate://crates.io/crossbeam-utils/0.8.11 \
    crate://crates.io/crypto-common/0.1.6 \
    crate://crates.io/crypto-mac/0.8.0 \
    crate://crates.io/darling/0.14.1 \
    crate://crates.io/darling_core/0.14.1 \
    crate://crates.io/darling_macro/0.14.1 \
    crate://crates.io/digest/0.10.3 \
    crate://crates.io/digest/0.9.0 \
    crate://crates.io/doc-comment/0.3.3 \
    crate://crates.io/either/1.7.0 \
    crate://crates.io/env_logger/0.9.0 \
    crate://crates.io/erased-serde/0.3.22 \
    crate://crates.io/filetime/0.2.17 \
    crate://crates.io/fnv/1.0.7 \
    crate://crates.io/foreign-types-shared/0.1.1 \
    crate://crates.io/foreign-types/0.3.2 \
    crate://crates.io/form_urlencoded/1.0.1 \
    crate://crates.io/fsevent-sys/2.0.1 \
    crate://crates.io/fsevent/0.4.0 \
    crate://crates.io/fuchsia-zircon-sys/0.3.3 \
    crate://crates.io/fuchsia-zircon/0.3.3 \
    crate://crates.io/futures-channel/0.3.21 \
    crate://crates.io/futures-core/0.3.21 \
    crate://crates.io/futures-executor/0.3.21 \
    crate://crates.io/futures-io/0.3.21 \
    crate://crates.io/futures-macro/0.3.21 \
    crate://crates.io/futures-sink/0.3.21 \
    crate://crates.io/futures-task/0.3.21 \
    crate://crates.io/futures-util/0.3.21 \
    crate://crates.io/futures/0.3.21 \
    crate://crates.io/generic-array/0.14.6 \
    crate://crates.io/getrandom/0.2.7 \
    crate://crates.io/gimli/0.26.2 \
    crate://crates.io/glob/0.3.0 \
    crate://crates.io/h2/0.3.13 \
    crate://crates.io/hashbrown/0.12.3 \
    crate://crates.io/headers-core/0.2.0 \
    crate://crates.io/headers/0.3.7 \
    crate://crates.io/heck/0.3.3 \
    crate://crates.io/hermit-abi/0.1.19 \
    crate://crates.io/hex/0.4.3 \
    crate://crates.io/hmac/0.8.1 \
    crate://crates.io/http-body/0.4.5 \
    crate://crates.io/http/0.2.8 \
    crate://crates.io/httparse/1.7.1 \
    crate://crates.io/httpdate/1.0.2 \
    crate://crates.io/humantime/2.1.0 \
    crate://crates.io/hyper-openssl/0.9.2 \
    crate://crates.io/hyper-proxy/0.9.1 \
    crate://crates.io/hyper/0.14.20 \
    crate://crates.io/ident_case/1.0.1 \
    crate://crates.io/idna/0.2.3 \
    crate://crates.io/indexmap/1.9.1 \
    crate://crates.io/inotify-sys/0.1.5 \
    crate://crates.io/inotify/0.7.1 \
    crate://crates.io/iovec/0.1.4 \
    crate://crates.io/itertools/0.8.2 \
    crate://crates.io/itoa/1.0.3 \
    crate://crates.io/js-sys/0.3.59 \
    crate://crates.io/kernel32-sys/0.2.2 \
    crate://crates.io/lazy_static/1.4.0 \
    crate://crates.io/lazycell/1.3.0 \
    crate://crates.io/libc/0.2.127 \
    crate://crates.io/libloading/0.7.3 \
    crate://crates.io/linked-hash-map/0.5.6 \
    crate://crates.io/linked_hash_set/0.1.4 \
    crate://crates.io/lock_api/0.4.7 \
    crate://crates.io/log/0.4.17 \
    crate://crates.io/matches/0.1.9 \
    crate://crates.io/memchr/2.5.0 \
    crate://crates.io/memoffset/0.6.5 \
    crate://crates.io/mime/0.3.16 \
    crate://crates.io/minimal-lexical/0.2.1 \
    crate://crates.io/miniz_oxide/0.5.3 \
    crate://crates.io/mio-extras/2.0.6 \
    crate://crates.io/mio/0.6.23 \
    crate://crates.io/mio/0.8.4 \
    crate://crates.io/miow/0.2.2 \
    crate://crates.io/net2/0.2.37 \
    crate://crates.io/nix/0.24.2 \
    crate://crates.io/nom/7.1.1 \
    crate://crates.io/notify/4.0.17 \
    crate://crates.io/ntapi/0.3.7 \
    crate://crates.io/num-integer/0.1.45 \
    crate://crates.io/num-traits/0.2.15 \
    crate://crates.io/num_cpus/1.13.1 \
    crate://crates.io/num_threads/0.1.6 \
    crate://crates.io/object/0.29.0 \
    crate://crates.io/once_cell/1.13.0 \
    crate://crates.io/opaque-debug/0.3.0 \
    crate://crates.io/openssl-errors/0.2.0 \
    crate://crates.io/openssl-macros/0.1.0 \
    crate://crates.io/openssl-sys/0.9.75 \
    crate://crates.io/openssl/0.10.41 \
    crate://crates.io/parking_lot/0.12.1 \
    crate://crates.io/parking_lot_core/0.9.3 \
    crate://crates.io/paste/1.0.8 \
    crate://crates.io/peeking_take_while/0.1.2 \
    crate://crates.io/percent-encoding/2.1.0 \
    crate://crates.io/pin-project-lite/0.2.9 \
    crate://crates.io/pin-utils/0.1.0 \
    crate://crates.io/pkg-config/0.3.25 \
    crate://crates.io/proc-macro-error-attr/1.0.4 \
    crate://crates.io/proc-macro-error/1.0.4 \
    crate://crates.io/proc-macro2/1.0.43 \
    crate://crates.io/quote/1.0.21 \
    crate://crates.io/rayon-core/1.9.3 \
    crate://crates.io/rayon/1.5.3 \
    crate://crates.io/redox_syscall/0.2.16 \
    crate://crates.io/regex-syntax/0.6.27 \
    crate://crates.io/regex/1.6.0 \
    crate://crates.io/rustc-demangle/0.1.21 \
    crate://crates.io/rustc-hash/1.1.0 \
    crate://crates.io/rustversion/1.0.9 \
    crate://crates.io/ryu/1.0.11 \
    crate://crates.io/same-file/1.0.6 \
    crate://crates.io/scopeguard/1.1.0 \
    crate://crates.io/serde/1.0.142 \
    crate://crates.io/serde_derive/1.0.142 \
    crate://crates.io/serde_json/1.0.83 \
    crate://crates.io/serde_with/2.0.0 \
    crate://crates.io/serde_with_macros/2.0.0 \
    crate://crates.io/serial_test/0.8.0 \
    crate://crates.io/serial_test_derive/0.8.0 \
    crate://crates.io/sha-1/0.10.0 \
    crate://crates.io/sha2/0.9.9 \
    crate://crates.io/shlex/1.1.0 \
    crate://crates.io/slab/0.4.7 \
    crate://crates.io/smallvec/1.9.0 \
    crate://crates.io/socket2/0.4.4 \
    crate://crates.io/strsim/0.10.0 \
    crate://crates.io/strsim/0.8.0 \
    crate://crates.io/structopt-derive/0.4.18 \
    crate://crates.io/structopt/0.3.26 \
    crate://crates.io/subtle/2.4.1 \
    crate://crates.io/syn/1.0.99 \
    crate://crates.io/sysinfo/0.15.9 \
    crate://crates.io/termcolor/1.1.3 \
    crate://crates.io/textwrap/0.11.0 \
    crate://crates.io/time/0.1.44 \
    crate://crates.io/time/0.3.13 \
    crate://crates.io/tinyvec/1.6.0 \
    crate://crates.io/tinyvec_macros/0.1.0 \
    crate://crates.io/tokio-macros/1.8.0 \
    crate://crates.io/tokio-openssl/0.6.3 \
    crate://crates.io/tokio-util/0.7.3 \
    crate://crates.io/tokio/1.20.1 \
    crate://crates.io/toml/0.5.9 \
    crate://crates.io/tower-layer/0.3.1 \
    crate://crates.io/tower-service/0.3.2 \
    crate://crates.io/tracing-attributes/0.1.22 \
    crate://crates.io/tracing-core/0.1.29 \
    crate://crates.io/tracing/0.1.36 \
    crate://crates.io/try-lock/0.2.3 \
    crate://crates.io/typenum/1.15.0 \
    crate://crates.io/unicode-bidi/0.3.8 \
    crate://crates.io/unicode-ident/1.0.3 \
    crate://crates.io/unicode-normalization/0.1.21 \
    crate://crates.io/unicode-segmentation/1.9.0 \
    crate://crates.io/unicode-width/0.1.9 \
    crate://crates.io/url/2.2.2 \
    crate://crates.io/utf8-width/0.1.6 \
    crate://crates.io/uuid/1.1.2 \
    crate://crates.io/vcpkg/0.2.15 \
    crate://crates.io/vec_map/0.8.2 \
    crate://crates.io/version_check/0.9.4 \
    crate://crates.io/walkdir/2.3.2 \
    crate://crates.io/want/0.3.0 \
    crate://crates.io/wasi/0.10.0+wasi-snapshot-preview1 \
    crate://crates.io/wasi/0.11.0+wasi-snapshot-preview1 \
    crate://crates.io/wasm-bindgen-backend/0.2.82 \
    crate://crates.io/wasm-bindgen-macro-support/0.2.82 \
    crate://crates.io/wasm-bindgen-macro/0.2.82 \
    crate://crates.io/wasm-bindgen-shared/0.2.82 \
    crate://crates.io/wasm-bindgen/0.2.82 \
    crate://crates.io/wildmatch/2.1.1 \
    crate://crates.io/winapi-build/0.1.1 \
    crate://crates.io/winapi-i686-pc-windows-gnu/0.4.0 \
    crate://crates.io/winapi-util/0.1.5 \
    crate://crates.io/winapi-x86_64-pc-windows-gnu/0.4.0 \
    crate://crates.io/winapi/0.2.8 \
    crate://crates.io/winapi/0.3.9 \
    crate://crates.io/windows-sys/0.36.1 \
    crate://crates.io/windows_aarch64_msvc/0.36.1 \
    crate://crates.io/windows_i686_gnu/0.36.1 \
    crate://crates.io/windows_i686_msvc/0.36.1 \
    crate://crates.io/windows_x86_64_gnu/0.36.1 \
    crate://crates.io/windows_x86_64_msvc/0.36.1 \
    crate://crates.io/ws2_32-sys/0.2.1 \
"

PV:append = ".${SRCPV}"

S = "${WORKDIR}/git"
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

    # we don't build tpm2-tss as part of this build
    rm -rf third-party/tpm2-tss

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

    ln -rs ${D}${libexecdir}/aziot-identity-service/aziotd ${D}${libexecdir}/aziot-identity-service/aziot-certd
    ln -rs ${D}${libexecdir}/aziot-identity-service/aziotd ${D}${libexecdir}/aziot-identity-service/aziot-identityd
    ln -rs ${D}${libexecdir}/aziot-identity-service/aziotd ${D}${libexecdir}/aziot-identity-service/aziot-keyd

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
    ln -rs ${D}/mnt/data/var/secrets ${D}/var/secrets

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
    install -m 0644     ${S}/cert/aziot-certd/aziot-certd.service.in ${D}${systemd_system_unitdir}/aziot-certd.service
    sed -i \
        -e 's/^After=\(.*\)$/After=\1 systemd-tmpfiles-setup.service/' \
        -e 's#^After=\(.*\)$#After=\1\nConditionPathExists=/etc/aziot/config.toml\nConditionPathExists=/etc/aziot/identityd/config.d/00-super.toml#' \
        -e 's#@libexecdir@#/usr/libexec#g' \
        -e '/Environment=\(.*\)$/d' \
        ${D}${systemd_system_unitdir}/aziot-certd.service
    install -m 0644     ${S}/cert/aziot-certd/aziot-certd.socket ${D}${systemd_system_unitdir}/aziot-certd.socket
    # enable identity service to create cert "device-id" (e.g. for x509 dps provisioning)
    install -m 0600 -o aziotcs -g aziotcs ${WORKDIR}/iot-identity-service-certd.template.toml ${D}${sysconfdir}/aziot/certd/config.d/aziotid.toml

    install -m 0644     ${S}/identity/aziot-identityd/aziot-identityd.service.in ${D}${systemd_system_unitdir}/aziot-identityd.service
    sed -i \
        -e 's/^After=\(.*\)$/After=\1 systemd-tmpfiles-setup.service/' \
        -e 's#^After=\(.*\)$#After=\1\nConditionPathExists=/etc/aziot/config.toml\nConditionPathExists=/etc/aziot/identityd/config.d/00-super.toml#' \
        -e 's#@libexecdir@#/usr/libexec#g' \
        -e '/Environment=\(.*\)$/d' \
        ${D}${systemd_system_unitdir}/aziot-identityd.service
    install -m 0644     ${S}/identity/aziot-identityd/aziot-identityd.socket ${D}${systemd_system_unitdir}/aziot-identityd.socket

    install -m 0644     ${S}/key/aziot-keyd/aziot-keyd.service.in ${D}${systemd_system_unitdir}/aziot-keyd.service
    sed -i \
        -e 's/^After=\(.*\)$/After=\1 systemd-tmpfiles-setup.service/' \
        -e 's#^After=\(.*\)$#After=\1\nConditionPathExists=/etc/aziot/config.toml\nConditionPathExists=/etc/aziot/identityd/config.d/00-super.toml#' \
        -e 's#@libexecdir@#/usr/libexec#g' \
        -e '/Environment=\(.*\)$/d' \
        ${D}${systemd_system_unitdir}/aziot-keyd.service
    install -m 0644     ${S}/key/aziot-keyd/aziot-keyd.socket ${D}${systemd_system_unitdir}/aziot-keyd.socket

    if ${@bb.utils.contains('MACHINE_FEATURES', 'tpm2', 'true', 'false', d)}; then
        install -m 0644     ${S}/tpm/aziot-tpmd/aziot-tpmd.service.in ${D}${systemd_system_unitdir}/aziot-tpmd.service
        sed -i \
            -e 's/^After=\(.*\)$/After=\1 systemd-tmpfiles-setup.service/' \
            -e 's#^After=\(.*\)$#After=\1\nConditionPathExists=/etc/aziot/config.toml\nConditionPathExists=/etc/aziot/identityd/config.d/00-super.toml#' \
            -e 's#@libexecdir@#/usr/libexec#g' \
            -e '/Environment=\(.*\)$/d' \
            ${D}${systemd_system_unitdir}/aziot-tpmd.service
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
