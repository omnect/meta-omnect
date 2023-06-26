# Auto-Generated by cargo-bitbake 0.3.16
#
inherit cargo

# If this is git based prefer versioned ones if they exist
# DEFAULT_PREFERENCE = "-1"

# how to get wifi-commissioning-gatt-service could be as easy as but default to a git checkout:
# SRC_URI += "crate://crates.io/wifi-commissioning-gatt-service/0.3.6"
SRC_URI += "git://github.com/omnect/wifi-commissioning-gatt-service;protocol=https;nobranch=1;branch=main"
SRCREV = "0ecedc3dfb61df77fe5ee11dc18b94c67460aa2c"
S = "${WORKDIR}/git"
CARGO_SRC_DIR = ""


# please note if you have entries that do not begin with crate://
# you must change them to how that package can be fetched
SRC_URI += " \
    crate://crates.io/aho-corasick/1.0.2 \
    crate://crates.io/async-trait/0.1.68 \
    crate://crates.io/atty/0.2.14 \
    crate://crates.io/autocfg/1.1.0 \
    crate://crates.io/bitflags/1.3.2 \
    crate://crates.io/block-buffer/0.9.0 \
    crate://crates.io/block-padding/0.2.1 \
    crate://crates.io/bluer/0.15.7 \
    crate://crates.io/bytes/1.4.0 \
    crate://crates.io/cfg-if/1.0.0 \
    crate://crates.io/clap/3.2.25 \
    crate://crates.io/clap_derive/3.2.25 \
    crate://crates.io/clap_lex/0.2.4 \
    crate://crates.io/cpufeatures/0.2.7 \
    crate://crates.io/custom_debug/0.5.1 \
    crate://crates.io/custom_debug_derive/0.5.1 \
    crate://crates.io/dbus-crossroads/0.5.2 \
    crate://crates.io/dbus-tokio/0.7.6 \
    crate://crates.io/dbus/0.9.7 \
    crate://crates.io/digest/0.9.0 \
    crate://crates.io/displaydoc/0.2.4 \
    crate://crates.io/enclose/1.1.8 \
    crate://crates.io/env_logger/0.8.4 \
    crate://crates.io/futures-channel/0.3.28 \
    crate://crates.io/futures-core/0.3.28 \
    crate://crates.io/futures-executor/0.3.28 \
    crate://crates.io/futures-io/0.3.28 \
    crate://crates.io/futures-macro/0.3.28 \
    crate://crates.io/futures-sink/0.3.28 \
    crate://crates.io/futures-task/0.3.28 \
    crate://crates.io/futures-util/0.3.28 \
    crate://crates.io/futures/0.3.28 \
    crate://crates.io/generic-array/0.14.7 \
    crate://crates.io/getrandom/0.2.10 \
    crate://crates.io/hashbrown/0.12.3 \
    crate://crates.io/heck/0.4.1 \
    crate://crates.io/hermit-abi/0.1.19 \
    crate://crates.io/hermit-abi/0.2.6 \
    crate://crates.io/hex/0.4.3 \
    crate://crates.io/humantime/2.1.0 \
    crate://crates.io/indexmap/1.9.3 \
    crate://crates.io/itoa/1.0.6 \
    crate://crates.io/keccak/0.1.4 \
    crate://crates.io/lazy_static/1.4.0 \
    crate://crates.io/libc/0.2.146 \
    crate://crates.io/libdbus-sys/0.2.5 \
    crate://crates.io/log/0.4.19 \
    crate://crates.io/macaddr/1.0.1 \
    crate://crates.io/memchr/2.5.0 \
    crate://crates.io/mio/0.8.8 \
    crate://crates.io/nix/0.26.2 \
    crate://crates.io/num-derive/0.3.3 \
    crate://crates.io/num-traits/0.2.15 \
    crate://crates.io/num_cpus/1.15.0 \
    crate://crates.io/once_cell/1.18.0 \
    crate://crates.io/opaque-debug/0.3.0 \
    crate://crates.io/os_str_bytes/6.5.1 \
    crate://crates.io/pin-project-internal/1.1.0 \
    crate://crates.io/pin-project-lite/0.2.9 \
    crate://crates.io/pin-project/1.1.0 \
    crate://crates.io/pin-utils/0.1.0 \
    crate://crates.io/pkg-config/0.3.27 \
    crate://crates.io/proc-macro-error-attr/1.0.4 \
    crate://crates.io/proc-macro-error/1.0.4 \
    crate://crates.io/proc-macro2/1.0.60 \
    crate://crates.io/quote/1.0.28 \
    crate://crates.io/regex-syntax/0.7.2 \
    crate://crates.io/regex/1.8.4 \
    crate://crates.io/rustversion/1.0.12 \
    crate://crates.io/ryu/1.0.13 \
    crate://crates.io/sd-notify/0.4.1 \
    crate://crates.io/serde/1.0.164 \
    crate://crates.io/serde_derive/1.0.164 \
    crate://crates.io/serde_json/1.0.96 \
    crate://crates.io/sha3/0.9.1 \
    crate://crates.io/signal-hook-registry/1.4.1 \
    crate://crates.io/slab/0.4.8 \
    crate://crates.io/socket2/0.4.9 \
    crate://crates.io/static_assertions/1.1.0 \
    crate://crates.io/strsim/0.10.0 \
    crate://crates.io/strum/0.24.1 \
    crate://crates.io/strum_macros/0.24.3 \
    crate://crates.io/syn/1.0.109 \
    crate://crates.io/syn/2.0.18 \
    crate://crates.io/synstructure/0.12.6 \
    crate://crates.io/termcolor/1.2.0 \
    crate://crates.io/textwrap/0.16.0 \
    crate://crates.io/tokio-macros/2.1.0 \
    crate://crates.io/tokio-stream/0.1.14 \
    crate://crates.io/tokio/1.28.2 \
    crate://crates.io/typenum/1.16.0 \
    crate://crates.io/unicode-ident/1.0.9 \
    crate://crates.io/unicode-xid/0.2.4 \
    crate://crates.io/uuid/1.3.3 \
    crate://crates.io/version_check/0.9.4 \
    crate://crates.io/wasi/0.11.0+wasi-snapshot-preview1 \
    crate://crates.io/winapi-i686-pc-windows-gnu/0.4.0 \
    crate://crates.io/winapi-util/0.1.5 \
    crate://crates.io/winapi-x86_64-pc-windows-gnu/0.4.0 \
    crate://crates.io/winapi/0.3.9 \
    crate://crates.io/windows-sys/0.48.0 \
    crate://crates.io/windows-targets/0.48.0 \
    crate://crates.io/windows_aarch64_gnullvm/0.48.0 \
    crate://crates.io/windows_aarch64_msvc/0.48.0 \
    crate://crates.io/windows_i686_gnu/0.48.0 \
    crate://crates.io/windows_i686_msvc/0.48.0 \
    crate://crates.io/windows_x86_64_gnu/0.48.0 \
    crate://crates.io/windows_x86_64_gnullvm/0.48.0 \
    crate://crates.io/windows_x86_64_msvc/0.48.0 \
    crate://crates.io/wpactrl/0.5.1 \
"



# FIXME: update generateme with the real MD5 of the license file
LIC_FILES_CHKSUM = " \
    file://MIT OR Apache-2.0;md5=generateme \
"

SUMMARY = "wifi-commissioning-gatt-service"
HOMEPAGE = "git@github.com:omnect/wifi-commissioning-gatt-service.git"
LICENSE = "MIT OR Apache-2.0"

# includes this file if it exists but does not fail
# this is useful for anything you may want to override from
# what cargo-bitbake generates.
include wifi-commissioning-gatt-service-${PV}.inc
include wifi-commissioning-gatt-service.inc
