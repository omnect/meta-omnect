# Auto-Generated by cargo-bitbake 0.3.16
#
inherit cargo

# If this is git based prefer versioned ones if they exist
# DEFAULT_PREFERENCE = "-1"

# how to get icsdm-device-service could be as easy as but default to a git checkout:
# SRC_URI += "crate://crates.io/icsdm-device-service/0.6.0"
SRC_URI += "git://git@github.com/JanZachmann/demo-portal-module.git;protocol=ssh;nobranch=1;branch=rename-crate"
SRCREV = "4de5c2d3815828db81722f9743413c260e69d3a6"
S = "${WORKDIR}/git"
CARGO_SRC_DIR = ""
PV:append = ".AUTOINC+4de5c2d381"

# please note if you have entries that do not begin with crate://
# you must change them to how that package can be fetched
SRC_URI += " \
    crate://crates.io/addr2line/0.17.0 \
    crate://crates.io/adler/1.0.2 \
    crate://crates.io/aho-corasick/0.7.18 \
    crate://crates.io/ansi_term/0.12.1 \
    crate://crates.io/async-trait/0.1.57 \
    crate://crates.io/atty/0.2.14 \
    crate://crates.io/autocfg/1.1.0 \
    crate://crates.io/backtrace/0.3.66 \
    crate://crates.io/base64/0.13.0 \
    crate://crates.io/bindgen/0.59.2 \
    crate://crates.io/bitflags/1.3.2 \
    crate://crates.io/block-buffer/0.10.2 \
    crate://crates.io/bytes/1.2.1 \
    crate://crates.io/cc/1.0.73 \
    crate://crates.io/cexpr/0.6.0 \
    crate://crates.io/cfg-if/1.0.0 \
    crate://crates.io/clang-sys/1.3.3 \
    crate://crates.io/clap/2.34.0 \
    crate://crates.io/cpufeatures/0.2.4 \
    crate://crates.io/crossbeam-channel/0.5.6 \
    crate://crates.io/crossbeam-utils/0.8.11 \
    crate://crates.io/crypto-common/0.1.6 \
    crate://crates.io/darling/0.13.4 \
    crate://crates.io/darling_core/0.13.4 \
    crate://crates.io/darling_macro/0.13.4 \
    crate://crates.io/default-env/0.1.1 \
    crate://crates.io/digest/0.10.3 \
    crate://crates.io/either/1.8.0 \
    crate://crates.io/env_logger/0.8.4 \
    crate://crates.io/env_logger/0.9.0 \
    crate://crates.io/filetime/0.2.17 \
    crate://crates.io/fnv/1.0.7 \
    crate://crates.io/foreign-types-shared/0.1.1 \
    crate://crates.io/foreign-types/0.3.2 \
    crate://crates.io/form_urlencoded/1.0.1 \
    crate://crates.io/fsevent-sys/4.1.0 \
    crate://crates.io/futures-channel/0.3.24 \
    crate://crates.io/futures-core/0.3.24 \
    crate://crates.io/futures-executor/0.3.24 \
    crate://crates.io/futures-io/0.3.24 \
    crate://crates.io/futures-macro/0.3.24 \
    crate://crates.io/futures-sink/0.3.24 \
    crate://crates.io/futures-task/0.3.24 \
    crate://crates.io/futures-util/0.3.24 \
    crate://crates.io/futures/0.3.24 \
    crate://crates.io/generic-array/0.14.6 \
    crate://crates.io/getrandom/0.2.7 \
    crate://crates.io/gimli/0.26.2 \
    crate://crates.io/glob/0.3.0 \
    crate://crates.io/h2/0.3.14 \
    crate://crates.io/hashbrown/0.12.3 \
    crate://crates.io/headers-core/0.2.0 \
    crate://crates.io/headers/0.3.7 \
    crate://crates.io/hermit-abi/0.1.19 \
    crate://crates.io/hex/0.4.3 \
    crate://crates.io/http-body/0.4.5 \
    crate://crates.io/http/0.2.8 \
    crate://crates.io/httparse/1.8.0 \
    crate://crates.io/httpdate/1.0.2 \
    crate://crates.io/humantime/2.1.0 \
    crate://crates.io/hyper-openssl/0.9.2 \
    crate://crates.io/hyper-proxy/0.9.1 \
    crate://crates.io/hyper-timeout/0.4.1 \
    crate://crates.io/hyper/0.14.20 \
    crate://crates.io/ident_case/1.0.1 \
    crate://crates.io/idna/0.2.3 \
    crate://crates.io/indexmap/1.9.1 \
    crate://crates.io/inotify-sys/0.1.5 \
    crate://crates.io/inotify/0.9.6 \
    crate://crates.io/itoa/1.0.3 \
    crate://crates.io/kqueue-sys/1.0.3 \
    crate://crates.io/kqueue/1.0.6 \
    crate://crates.io/lazy_static/1.4.0 \
    crate://crates.io/lazycell/1.3.0 \
    crate://crates.io/libc/0.2.132 \
    crate://crates.io/libloading/0.7.3 \
    crate://crates.io/linked-hash-map/0.5.6 \
    crate://crates.io/linked_hash_set/0.1.4 \
    crate://crates.io/lock_api/0.4.8 \
    crate://crates.io/log-panics/2.1.0 \
    crate://crates.io/log/0.4.17 \
    crate://crates.io/matches/0.1.9 \
    crate://crates.io/memchr/2.5.0 \
    crate://crates.io/memoffset/0.6.5 \
    crate://crates.io/mime/0.3.16 \
    crate://crates.io/minimal-lexical/0.2.1 \
    crate://crates.io/miniz_oxide/0.5.4 \
    crate://crates.io/mio/0.8.4 \
    crate://crates.io/nix/0.23.1 \
    crate://crates.io/nom/7.1.1 \
    crate://crates.io/notify-debouncer-mini/0.2.0 \
    crate://crates.io/notify/5.0.0 \
    crate://crates.io/num_cpus/1.13.1 \
    crate://crates.io/num_threads/0.1.6 \
    crate://crates.io/object/0.29.0 \
    crate://crates.io/once_cell/1.13.1 \
    crate://crates.io/openssl-macros/0.1.0 \
    crate://crates.io/openssl-sys/0.9.75 \
    crate://crates.io/openssl/0.10.41 \
    crate://crates.io/parking_lot/0.12.1 \
    crate://crates.io/parking_lot_core/0.9.3 \
    crate://crates.io/peeking_take_while/0.1.2 \
    crate://crates.io/percent-encoding/2.1.0 \
    crate://crates.io/pin-project-lite/0.2.9 \
    crate://crates.io/pin-utils/0.1.0 \
    crate://crates.io/pkg-config/0.3.25 \
    crate://crates.io/ppv-lite86/0.2.16 \
    crate://crates.io/proc-macro2/0.4.30 \
    crate://crates.io/proc-macro2/1.0.43 \
    crate://crates.io/quote/0.6.13 \
    crate://crates.io/quote/1.0.21 \
    crate://crates.io/rand/0.8.5 \
    crate://crates.io/rand_chacha/0.3.1 \
    crate://crates.io/rand_core/0.6.3 \
    crate://crates.io/redox_syscall/0.2.16 \
    crate://crates.io/regex-syntax/0.6.27 \
    crate://crates.io/regex/1.6.0 \
    crate://crates.io/rustc-demangle/0.1.21 \
    crate://crates.io/rustc-hash/1.1.0 \
    crate://crates.io/ryu/1.0.11 \
    crate://crates.io/same-file/1.0.6 \
    crate://crates.io/scopeguard/1.1.0 \
    crate://crates.io/sd-notify/0.4.1 \
    crate://crates.io/serde/1.0.144 \
    crate://crates.io/serde_derive/1.0.144 \
    crate://crates.io/serde_json/1.0.85 \
    crate://crates.io/serde_with/1.14.0 \
    crate://crates.io/serde_with_macros/1.5.2 \
    crate://crates.io/sha-1/0.10.0 \
    crate://crates.io/shlex/1.1.0 \
    crate://crates.io/signal-hook-registry/1.4.0 \
    crate://crates.io/slab/0.4.7 \
    crate://crates.io/smallvec/1.9.0 \
    crate://crates.io/socket2/0.4.7 \
    crate://crates.io/strsim/0.10.0 \
    crate://crates.io/strsim/0.8.0 \
    crate://crates.io/syn/0.15.44 \
    crate://crates.io/syn/1.0.99 \
    crate://crates.io/termcolor/1.1.3 \
    crate://crates.io/textwrap/0.11.0 \
    crate://crates.io/time/0.3.14 \
    crate://crates.io/tinyvec/1.6.0 \
    crate://crates.io/tinyvec_macros/0.1.0 \
    crate://crates.io/tokio-io-timeout/1.2.0 \
    crate://crates.io/tokio-macros/1.8.0 \
    crate://crates.io/tokio-openssl/0.6.3 \
    crate://crates.io/tokio-util/0.7.3 \
    crate://crates.io/tokio/1.20.1 \
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
    crate://crates.io/unicode-width/0.1.9 \
    crate://crates.io/unicode-xid/0.1.0 \
    crate://crates.io/url/2.2.2 \
    crate://crates.io/vcpkg/0.2.15 \
    crate://crates.io/vec_map/0.8.2 \
    crate://crates.io/version_check/0.9.4 \
    crate://crates.io/walkdir/2.3.2 \
    crate://crates.io/want/0.3.0 \
    crate://crates.io/wasi/0.11.0+wasi-snapshot-preview1 \
    crate://crates.io/which/4.3.0 \
    crate://crates.io/winapi-i686-pc-windows-gnu/0.4.0 \
    crate://crates.io/winapi-util/0.1.5 \
    crate://crates.io/winapi-x86_64-pc-windows-gnu/0.4.0 \
    crate://crates.io/winapi/0.3.9 \
    crate://crates.io/windows-sys/0.36.1 \
    crate://crates.io/windows_aarch64_msvc/0.36.1 \
    crate://crates.io/windows_i686_gnu/0.36.1 \
    crate://crates.io/windows_i686_msvc/0.36.1 \
    crate://crates.io/windows_x86_64_gnu/0.36.1 \
    crate://crates.io/windows_x86_64_msvc/0.36.1 \
    git://git@github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;name=aziot-cert-client-async;destsuffix=aziot-cert-client-async \
    git://git@github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;name=aziot-cert-common-http;destsuffix=aziot-cert-common-http \
    git://git@github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;name=aziot-cert-common;destsuffix=aziot-cert-common \
    git://git@github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;name=aziot-certd-config;destsuffix=aziot-certd-config \
    git://git@github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;name=aziot-identity-client-async;destsuffix=aziot-identity-client-async \
    git://git@github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;name=aziot-identity-common-http;destsuffix=aziot-identity-common-http \
    git://git@github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;name=aziot-identity-common;destsuffix=aziot-identity-common \
    git://git@github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;name=aziot-identityd-config;destsuffix=aziot-identityd-config \
    git://git@github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;name=aziot-key-client-async;destsuffix=aziot-key-client-async \
    git://git@github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;name=aziot-key-common-http;destsuffix=aziot-key-common-http \
    git://git@github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;name=aziot-key-common;destsuffix=aziot-key-common \
    git://git@github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;name=aziot-keyd-config;destsuffix=aziot-keyd-config \
    git://git@github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;name=http-common;destsuffix=http-common \
    git://git@github.com/ICS-DeviceManagement/azure-iot-sdk-sys.git;protocol=ssh;nobranch=1;name=azure-iot-sdk-sys;destsuffix=azure-iot-sdk-sys \
    git://git@github.com/ICS-DeviceManagement/azure-iot-sdk.git;protocol=ssh;nobranch=1;name=azure-iot-sdk;destsuffix=azure-iot-sdk \
    git://git@github.com/ICS-DeviceManagement/eis-utils.git;protocol=ssh;nobranch=1;name=eis-utils;destsuffix=eis-utils \
"

SRCREV_FORMAT .= "_aziot-cert-client-async"
SRCREV_aziot-cert-client-async = "6af42eefc84351ec7af510213561a40948ed9045"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-cert-client-async"
SRCREV_FORMAT .= "_aziot-cert-common"
SRCREV_aziot-cert-common = "6af42eefc84351ec7af510213561a40948ed9045"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-cert-common"
SRCREV_FORMAT .= "_aziot-cert-common-http"
SRCREV_aziot-cert-common-http = "6af42eefc84351ec7af510213561a40948ed9045"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-cert-common-http"
SRCREV_FORMAT .= "_aziot-certd-config"
SRCREV_aziot-certd-config = "6af42eefc84351ec7af510213561a40948ed9045"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-certd-config"
SRCREV_FORMAT .= "_aziot-identity-client-async"
SRCREV_aziot-identity-client-async = "6af42eefc84351ec7af510213561a40948ed9045"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-identity-client-async"
SRCREV_FORMAT .= "_aziot-identity-common"
SRCREV_aziot-identity-common = "6af42eefc84351ec7af510213561a40948ed9045"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-identity-common"
SRCREV_FORMAT .= "_aziot-identity-common-http"
SRCREV_aziot-identity-common-http = "6af42eefc84351ec7af510213561a40948ed9045"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-identity-common-http"
SRCREV_FORMAT .= "_aziot-identityd-config"
SRCREV_aziot-identityd-config = "6af42eefc84351ec7af510213561a40948ed9045"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-identityd-config"
SRCREV_FORMAT .= "_aziot-key-client-async"
SRCREV_aziot-key-client-async = "6af42eefc84351ec7af510213561a40948ed9045"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-key-client-async"
SRCREV_FORMAT .= "_aziot-key-common"
SRCREV_aziot-key-common = "6af42eefc84351ec7af510213561a40948ed9045"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-key-common"
SRCREV_FORMAT .= "_aziot-key-common-http"
SRCREV_aziot-key-common-http = "6af42eefc84351ec7af510213561a40948ed9045"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-key-common-http"
SRCREV_FORMAT .= "_aziot-keyd-config"
SRCREV_aziot-keyd-config = "6af42eefc84351ec7af510213561a40948ed9045"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-keyd-config"
SRCREV_FORMAT .= "_azure-iot-sdk"
SRCREV_azure-iot-sdk = "0.8.4"
EXTRA_OECARGO_PATHS += "${WORKDIR}/azure-iot-sdk"
SRCREV_FORMAT .= "_azure-iot-sdk-sys"
SRCREV_azure-iot-sdk-sys = "0.5.2"
EXTRA_OECARGO_PATHS += "${WORKDIR}/azure-iot-sdk-sys"
SRCREV_FORMAT .= "_eis-utils"
SRCREV_eis-utils = "0.2.2"
EXTRA_OECARGO_PATHS += "${WORKDIR}/eis-utils"
SRCREV_FORMAT .= "_http-common"
SRCREV_http-common = "6af42eefc84351ec7af510213561a40948ed9045"
EXTRA_OECARGO_PATHS += "${WORKDIR}/http-common"

# FIXME: update generateme with the real MD5 of the license file
LIC_FILES_CHKSUM = " \
    file://MIT OR Apache-2.0;md5=generateme \
"

SUMMARY = "icsdm-device-service"
HOMEPAGE = "git@github.com:ICS-DeviceManagement/icsdm-device-service.git"
LICENSE = "MIT OR Apache-2.0"

# includes this file if it exists but does not fail
# this is useful for anything you may want to override from
# what cargo-bitbake generates.
include icsdm-device-service-${PV}.inc
include icsdm-device-service.inc
