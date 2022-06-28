# Auto-Generated by cargo-bitbake 0.3.16-alpha.0
#
# Manually Adapted:
#   - name of recipe
inherit cargo

# If this is git based prefer versioned ones if they exist
# DEFAULT_PREFERENCE = "-1"

# how to get aziot-edged could be as easy as but default to a git checkout:
# SRC_URI += "crate://crates.io/aziot-edged/0.1.0"
SRC_URI += "git://git@github.com/Azure/iotedge.git;protocol=ssh;nobranch=1"
SRCREV = "b022069058d21deb30c7760c4e384b637694f464"
S = "${WORKDIR}/git"
CARGO_SRC_DIR = "aziot-edged"


# please note if you have entries that do not begin with crate://
# you must change them to how that package can be fetched
SRC_URI += " \
    crate://crates.io/adler/1.0.2 \
    crate://crates.io/aho-corasick/0.7.18 \
    crate://crates.io/ansi_term/0.11.0 \
    crate://crates.io/anyhow/1.0.44 \
    crate://crates.io/arrayvec/0.5.2 \
    crate://crates.io/async-trait/0.1.52 \
    crate://crates.io/atty/0.2.14 \
    crate://crates.io/autocfg/1.1.0 \
    crate://crates.io/base64/0.13.0 \
    crate://crates.io/bitflags/1.2.1 \
    crate://crates.io/block-buffer/0.9.0 \
    crate://crates.io/byte-unit/3.1.4 \
    crate://crates.io/byteorder/1.4.3 \
    crate://crates.io/bytes/1.1.0 \
    crate://crates.io/bzip2-sys/0.1.11+1.0.8 \
    crate://crates.io/bzip2/0.4.3 \
    crate://crates.io/cc/1.0.71 \
    crate://crates.io/cfg-if/1.0.0 \
    crate://crates.io/chrono-humanize/0.0.11 \
    crate://crates.io/chrono/0.4.19 \
    crate://crates.io/clap/2.33.3 \
    crate://crates.io/config/0.11.0 \
    crate://crates.io/consistenttime/0.2.0 \
    crate://crates.io/core-foundation-sys/0.8.3 \
    crate://crates.io/cpufeatures/0.2.1 \
    crate://crates.io/crc32fast/1.2.1 \
    crate://crates.io/crossbeam-channel/0.5.2 \
    crate://crates.io/crossbeam-deque/0.8.1 \
    crate://crates.io/crossbeam-epoch/0.9.7 \
    crate://crates.io/crossbeam-utils/0.8.7 \
    crate://crates.io/darling/0.13.0 \
    crate://crates.io/darling_core/0.13.0 \
    crate://crates.io/darling_macro/0.13.0 \
    crate://crates.io/digest/0.9.0 \
    crate://crates.io/either/1.6.1 \
    crate://crates.io/env_logger/0.9.0 \
    crate://crates.io/erased-serde/0.3.16 \
    crate://crates.io/flate2/1.0.22 \
    crate://crates.io/fnv/1.0.7 \
    crate://crates.io/foreign-types-shared/0.1.1 \
    crate://crates.io/foreign-types/0.3.2 \
    crate://crates.io/form_urlencoded/1.0.1 \
    crate://crates.io/futures-channel/0.3.17 \
    crate://crates.io/futures-core/0.3.17 \
    crate://crates.io/futures-executor/0.3.17 \
    crate://crates.io/futures-io/0.3.17 \
    crate://crates.io/futures-macro/0.3.17 \
    crate://crates.io/futures-sink/0.3.17 \
    crate://crates.io/futures-task/0.3.17 \
    crate://crates.io/futures-util/0.3.17 \
    crate://crates.io/futures/0.3.17 \
    crate://crates.io/generic-array/0.14.4 \
    crate://crates.io/getrandom/0.2.3 \
    crate://crates.io/h2/0.3.13 \
    crate://crates.io/hashbrown/0.11.2 \
    crate://crates.io/headers-core/0.2.0 \
    crate://crates.io/headers/0.3.5 \
    crate://crates.io/hermit-abi/0.1.19 \
    crate://crates.io/hex/0.4.3 \
    crate://crates.io/http-body/0.4.4 \
    crate://crates.io/http/0.2.6 \
    crate://crates.io/httparse/1.7.0 \
    crate://crates.io/httpdate/1.0.1 \
    crate://crates.io/humantime/2.1.0 \
    crate://crates.io/hyper-openssl/0.9.2 \
    crate://crates.io/hyper-proxy/0.9.1 \
    crate://crates.io/hyper/0.14.18 \
    crate://crates.io/ident_case/1.0.1 \
    crate://crates.io/idna/0.2.3 \
    crate://crates.io/indexmap/1.7.0 \
    crate://crates.io/itoa/1.0.1 \
    crate://crates.io/lazy_static/1.4.0 \
    crate://crates.io/lexical-core/0.7.6 \
    crate://crates.io/libc/0.2.123 \
    crate://crates.io/linked-hash-map/0.5.4 \
    crate://crates.io/linked_hash_set/0.1.4 \
    crate://crates.io/lock_api/0.4.7 \
    crate://crates.io/log/0.4.14 \
    crate://crates.io/matches/0.1.9 \
    crate://crates.io/memchr/2.4.1 \
    crate://crates.io/memoffset/0.6.4 \
    crate://crates.io/mime/0.3.16 \
    crate://crates.io/miniz_oxide/0.4.4 \
    crate://crates.io/mio/0.7.14 \
    crate://crates.io/miow/0.3.7 \
    crate://crates.io/nix/0.23.1 \
    crate://crates.io/nom/5.1.2 \
    crate://crates.io/ntapi/0.3.6 \
    crate://crates.io/num-integer/0.1.44 \
    crate://crates.io/num-traits/0.2.14 \
    crate://crates.io/num_cpus/1.13.0 \
    crate://crates.io/once_cell/1.8.0 \
    crate://crates.io/opaque-debug/0.3.0 \
    crate://crates.io/openssl-errors/0.1.0 \
    crate://crates.io/openssl-sys/0.9.67 \
    crate://crates.io/openssl/0.10.36 \
    crate://crates.io/parking_lot/0.12.0 \
    crate://crates.io/parking_lot_core/0.9.2 \
    crate://crates.io/percent-encoding/2.1.0 \
    crate://crates.io/pin-project-lite/0.2.7 \
    crate://crates.io/pin-utils/0.1.0 \
    crate://crates.io/pkg-config/0.3.22 \
    crate://crates.io/ppv-lite86/0.2.15 \
    crate://crates.io/proc-macro-hack/0.5.19 \
    crate://crates.io/proc-macro-nested/0.1.7 \
    crate://crates.io/proc-macro2/1.0.30 \
    crate://crates.io/quote/1.0.10 \
    crate://crates.io/rand/0.8.4 \
    crate://crates.io/rand_chacha/0.3.1 \
    crate://crates.io/rand_core/0.6.3 \
    crate://crates.io/rand_hc/0.3.1 \
    crate://crates.io/rayon-core/1.9.1 \
    crate://crates.io/rayon/1.5.1 \
    crate://crates.io/redox_syscall/0.2.10 \
    crate://crates.io/regex-syntax/0.6.25 \
    crate://crates.io/regex/1.5.5 \
    crate://crates.io/remove_dir_all/0.5.3 \
    crate://crates.io/rustversion/1.0.5 \
    crate://crates.io/ryu/1.0.5 \
    crate://crates.io/scopeguard/1.1.0 \
    crate://crates.io/serde/1.0.130 \
    crate://crates.io/serde_derive/1.0.130 \
    crate://crates.io/serde_json/1.0.79 \
    crate://crates.io/serde_with/1.11.0 \
    crate://crates.io/serde_with_macros/1.5.1 \
    crate://crates.io/sha-1/0.9.8 \
    crate://crates.io/sha2/0.9.8 \
    crate://crates.io/signal-hook-registry/1.4.0 \
    crate://crates.io/slab/0.4.5 \
    crate://crates.io/smallvec/1.7.0 \
    crate://crates.io/socket2/0.4.2 \
    crate://crates.io/static_assertions/1.1.0 \
    crate://crates.io/strsim/0.10.0 \
    crate://crates.io/strsim/0.8.0 \
    crate://crates.io/syn/1.0.80 \
    crate://crates.io/sysinfo/0.23.10 \
    crate://crates.io/tabwriter/1.2.1 \
    crate://crates.io/tempfile/3.2.0 \
    crate://crates.io/termcolor/1.1.2 \
    crate://crates.io/test-case/1.2.0 \
    crate://crates.io/textwrap/0.11.0 \
    crate://crates.io/thiserror-impl/1.0.30 \
    crate://crates.io/thiserror/1.0.30 \
    crate://crates.io/time/0.1.43 \
    crate://crates.io/tinyvec/1.5.0 \
    crate://crates.io/tinyvec_macros/0.1.0 \
    crate://crates.io/tokio-macros/1.7.0 \
    crate://crates.io/tokio-openssl/0.6.3 \
    crate://crates.io/tokio-util/0.7.1 \
    crate://crates.io/tokio/1.16.1 \
    crate://crates.io/toml/0.5.8 \
    crate://crates.io/tower-layer/0.3.1 \
    crate://crates.io/tower-service/0.3.1 \
    crate://crates.io/tracing-attributes/0.1.18 \
    crate://crates.io/tracing-core/0.1.21 \
    crate://crates.io/tracing/0.1.29 \
    crate://crates.io/try-lock/0.2.3 \
    crate://crates.io/typenum/1.14.0 \
    crate://crates.io/unicode-bidi/0.3.7 \
    crate://crates.io/unicode-normalization/0.1.19 \
    crate://crates.io/unicode-width/0.1.9 \
    crate://crates.io/unicode-xid/0.2.2 \
    crate://crates.io/url/2.2.2 \
    crate://crates.io/vcpkg/0.2.15 \
    crate://crates.io/vec_map/0.8.2 \
    crate://crates.io/version_check/0.9.3 \
    crate://crates.io/want/0.3.0 \
    crate://crates.io/wasi/0.10.2+wasi-snapshot-preview1 \
    crate://crates.io/winapi-i686-pc-windows-gnu/0.4.0 \
    crate://crates.io/winapi-util/0.1.5 \
    crate://crates.io/winapi-x86_64-pc-windows-gnu/0.4.0 \
    crate://crates.io/winapi/0.3.9 \
    crate://crates.io/windows-sys/0.34.0 \
    crate://crates.io/windows_aarch64_msvc/0.34.0 \
    crate://crates.io/windows_i686_gnu/0.34.0 \
    crate://crates.io/windows_i686_msvc/0.34.0 \
    crate://crates.io/windows_x86_64_gnu/0.34.0 \
    crate://crates.io/windows_x86_64_msvc/0.34.0 \
    crate://crates.io/yaml-rust/0.4.5 \
    crate://crates.io/zip/0.5.13 \
    git://github.com/Azure/iot-identity-service;protocol=https;nobranch=1;name=aziot-cert-client-async;destsuffix=aziot-cert-client-async \
    git://github.com/Azure/iot-identity-service;protocol=https;nobranch=1;name=aziot-cert-common-http;destsuffix=aziot-cert-common-http \
    git://github.com/Azure/iot-identity-service;protocol=https;nobranch=1;name=aziot-certd-config;destsuffix=aziot-certd-config \
    git://github.com/Azure/iot-identity-service;protocol=https;nobranch=1;name=aziot-identity-client-async;destsuffix=aziot-identity-client-async \
    git://github.com/Azure/iot-identity-service;protocol=https;nobranch=1;name=aziot-identity-common-http;destsuffix=aziot-identity-common-http \
    git://github.com/Azure/iot-identity-service;protocol=https;nobranch=1;name=aziot-identity-common;destsuffix=aziot-identity-common \
    git://github.com/Azure/iot-identity-service;protocol=https;nobranch=1;name=aziot-identityd-config;destsuffix=aziot-identityd-config \
    git://github.com/Azure/iot-identity-service;protocol=https;nobranch=1;name=aziot-key-client-async;destsuffix=aziot-key-client-async \
    git://github.com/Azure/iot-identity-service;protocol=https;nobranch=1;name=aziot-key-client;destsuffix=aziot-key-client \
    git://github.com/Azure/iot-identity-service;protocol=https;nobranch=1;name=aziot-key-common-http;destsuffix=aziot-key-common-http \
    git://github.com/Azure/iot-identity-service;protocol=https;nobranch=1;name=aziot-key-common;destsuffix=aziot-key-common \
    git://github.com/Azure/iot-identity-service;protocol=https;nobranch=1;name=aziot-key-openssl-engine;destsuffix=aziot-key-openssl-engine \
    git://github.com/Azure/iot-identity-service;protocol=https;nobranch=1;name=aziot-keyd-config;destsuffix=aziot-keyd-config \
    git://github.com/Azure/iot-identity-service;protocol=https;nobranch=1;name=aziot-keys-common;destsuffix=aziot-keys-common \
    git://github.com/Azure/iot-identity-service;protocol=https;nobranch=1;name=aziot-tpmd-config;destsuffix=aziot-tpmd-config \
    git://github.com/Azure/iot-identity-service;protocol=https;nobranch=1;name=aziotctl-common;destsuffix=aziotctl-common \
    git://github.com/Azure/iot-identity-service;protocol=https;nobranch=1;name=cert-renewal;destsuffix=cert-renewal \
    git://github.com/Azure/iot-identity-service;protocol=https;nobranch=1;name=config-common;destsuffix=config-common \
    git://github.com/Azure/iot-identity-service;protocol=https;nobranch=1;name=config-common;destsuffix=config-common \
    git://github.com/Azure/iot-identity-service;protocol=https;nobranch=1;name=http-common;destsuffix=http-common \
    git://github.com/Azure/iot-identity-service;protocol=https;nobranch=1;name=logger;destsuffix=logger \
    git://github.com/Azure/iot-identity-service;protocol=https;nobranch=1;name=openssl-build;destsuffix=openssl-build \
    git://github.com/Azure/iot-identity-service;protocol=https;nobranch=1;name=openssl-sys2;destsuffix=openssl-sys2 \
    git://github.com/Azure/iot-identity-service;protocol=https;nobranch=1;name=openssl2;destsuffix=openssl2 \
    git://github.com/Azure/iot-identity-service;protocol=https;nobranch=1;name=pkcs11-sys;destsuffix=pkcs11-sys \
    git://github.com/Azure/iot-identity-service;protocol=https;nobranch=1;name=pkcs11;destsuffix=pkcs11 \
    git://github.com/Azure/iot-identity-service;protocol=https;nobranch=1;name=test-common;destsuffix=test-common \
"

SRCREV_FORMAT .= "_aziot-cert-client-async"
SRCREV_aziot-cert-client-async = "release/1.3"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-cert-client-async"
SRCREV_FORMAT .= "_aziot-cert-common-http"
SRCREV_aziot-cert-common-http = "release/1.3"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-cert-common-http"
SRCREV_FORMAT .= "_aziot-certd-config"
SRCREV_aziot-certd-config = "release/1.3"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-certd-config"
SRCREV_FORMAT .= "_aziot-identity-client-async"
SRCREV_aziot-identity-client-async = "release/1.3"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-identity-client-async"
SRCREV_FORMAT .= "_aziot-identity-common"
SRCREV_aziot-identity-common = "release/1.3"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-identity-common"
SRCREV_FORMAT .= "_aziot-identity-common-http"
SRCREV_aziot-identity-common-http = "release/1.3"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-identity-common-http"
SRCREV_FORMAT .= "_aziot-identityd-config"
SRCREV_aziot-identityd-config = "release/1.3"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-identityd-config"
SRCREV_FORMAT .= "_aziot-key-client"
SRCREV_aziot-key-client = "release/1.3"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-key-client"
SRCREV_FORMAT .= "_aziot-key-client-async"
SRCREV_aziot-key-client-async = "release/1.3"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-key-client-async"
SRCREV_FORMAT .= "_aziot-key-common"
SRCREV_aziot-key-common = "release/1.3"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-key-common"
SRCREV_FORMAT .= "_aziot-key-common-http"
SRCREV_aziot-key-common-http = "release/1.3"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-key-common-http"
SRCREV_FORMAT .= "_aziot-key-openssl-engine"
SRCREV_aziot-key-openssl-engine = "release/1.3"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-key-openssl-engine"
SRCREV_FORMAT .= "_aziot-keyd-config"
SRCREV_aziot-keyd-config = "release/1.3"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-keyd-config"
SRCREV_FORMAT .= "_aziot-keys-common"
SRCREV_aziot-keys-common = "release/1.3"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-keys-common"
SRCREV_FORMAT .= "_aziot-tpmd-config"
SRCREV_aziot-tpmd-config = "release/1.3"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-tpmd-config"
SRCREV_FORMAT .= "_aziotctl-common"
SRCREV_aziotctl-common = "release/1.3"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziotctl-common"
SRCREV_FORMAT .= "_cert-renewal"
SRCREV_cert-renewal = "release/1.3"
EXTRA_OECARGO_PATHS += "${WORKDIR}/cert-renewal"
SRCREV_FORMAT .= "_config-common"
SRCREV_config-common = "main"
EXTRA_OECARGO_PATHS += "${WORKDIR}/config-common"
SRCREV_FORMAT .= "_config-common"
SRCREV_config-common = "release/1.3"
EXTRA_OECARGO_PATHS += "${WORKDIR}/config-common"
SRCREV_FORMAT .= "_http-common"
SRCREV_http-common = "release/1.3"
EXTRA_OECARGO_PATHS += "${WORKDIR}/http-common"
SRCREV_FORMAT .= "_logger"
SRCREV_logger = "release/1.3"
EXTRA_OECARGO_PATHS += "${WORKDIR}/logger"
SRCREV_FORMAT .= "_openssl-build"
SRCREV_openssl-build = "release/1.3"
EXTRA_OECARGO_PATHS += "${WORKDIR}/openssl-build"
SRCREV_FORMAT .= "_openssl-sys2"
SRCREV_openssl-sys2 = "release/1.3"
EXTRA_OECARGO_PATHS += "${WORKDIR}/openssl-sys2"
SRCREV_FORMAT .= "_openssl2"
SRCREV_openssl2 = "release/1.3"
EXTRA_OECARGO_PATHS += "${WORKDIR}/openssl2"
SRCREV_FORMAT .= "_pkcs11"
SRCREV_pkcs11 = "release/1.3"
EXTRA_OECARGO_PATHS += "${WORKDIR}/pkcs11"
SRCREV_FORMAT .= "_pkcs11-sys"
SRCREV_pkcs11-sys = "release/1.3"
EXTRA_OECARGO_PATHS += "${WORKDIR}/pkcs11-sys"
SRCREV_FORMAT .= "_test-common"
SRCREV_test-common = "release/1.3"
EXTRA_OECARGO_PATHS += "${WORKDIR}/test-common"

# FIXME: update generateme with the real MD5 of the license file
LIC_FILES_CHKSUM = " \
    "

SUMMARY = "aziot-edged"
HOMEPAGE = "https://github.com/Azure/iotedge"
LICENSE = "CLOSED"

# includes this file if it exists but does not fail
# this is useful for anything you may want to override from
# what cargo-bitbake generates.
include iotedge-daemon_${PV}.inc
include iotedge-daemon.inc
