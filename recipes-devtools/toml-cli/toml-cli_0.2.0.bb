# Auto-Generated by cargo-bitbake 0.3.15
#
inherit cargo

# If this is git based prefer versioned ones if they exist
# DEFAULT_PREFERENCE = "-1"

# how to get toml-cli could be as easy as but default to a git checkout:
# SRC_URI += "crate://crates.io/toml-cli/0.2.0"
SRC_URI += "git://github.com/gnprice/toml-cli.git;protocol=https;nobranch=1"
SRCREV = "4706330cfa399b44f6140de30ffb37b51b5b1c36"
S = "${WORKDIR}/git"
CARGO_SRC_DIR = ""


# please note if you have entries that do not begin with crate://
# you must change them to how that package can be fetched
SRC_URI += " \
    crate://crates.io/ansi_term/0.11.0 \
    crate://crates.io/arrayvec/0.4.12 \
    crate://crates.io/atty/0.2.13 \
    crate://crates.io/autocfg/1.0.1 \
    crate://crates.io/backtrace-sys/0.1.31 \
    crate://crates.io/backtrace/0.3.35 \
    crate://crates.io/bitflags/1.1.0 \
    crate://crates.io/bytes/1.1.0 \
    crate://crates.io/cc/1.0.41 \
    crate://crates.io/cfg-if/0.1.9 \
    crate://crates.io/chrono/0.4.19 \
    crate://crates.io/clap/2.33.0 \
    crate://crates.io/combine/4.6.2 \
    crate://crates.io/failure/0.1.5 \
    crate://crates.io/failure_derive/0.1.5 \
    crate://crates.io/heck/0.3.1 \
    crate://crates.io/itoa/0.4.4 \
    crate://crates.io/lexical-core/0.4.8 \
    crate://crates.io/libc/0.2.108 \
    crate://crates.io/linked-hash-map/0.5.4 \
    crate://crates.io/memchr/2.2.1 \
    crate://crates.io/nodrop/0.1.14 \
    crate://crates.io/nom/5.0.1 \
    crate://crates.io/num-integer/0.1.44 \
    crate://crates.io/num-traits/0.2.14 \
    crate://crates.io/proc-macro-error/0.2.4 \
    crate://crates.io/proc-macro2/0.4.30 \
    crate://crates.io/proc-macro2/1.0.2 \
    crate://crates.io/quote/0.6.13 \
    crate://crates.io/quote/1.0.2 \
    crate://crates.io/rustc-demangle/0.1.16 \
    crate://crates.io/rustc_version/0.2.3 \
    crate://crates.io/ryu/1.0.0 \
    crate://crates.io/semver-parser/0.7.0 \
    crate://crates.io/semver/0.9.0 \
    crate://crates.io/serde/1.0.99 \
    crate://crates.io/serde_json/1.0.40 \
    crate://crates.io/static_assertions/0.3.4 \
    crate://crates.io/strsim/0.8.0 \
    crate://crates.io/structopt-derive/0.3.0 \
    crate://crates.io/structopt/0.3.0 \
    crate://crates.io/syn/0.15.44 \
    crate://crates.io/syn/1.0.5 \
    crate://crates.io/synstructure/0.10.2 \
    crate://crates.io/textwrap/0.11.0 \
    crate://crates.io/time/0.1.44 \
    crate://crates.io/toml_edit/0.2.1 \
    crate://crates.io/unicode-segmentation/1.3.0 \
    crate://crates.io/unicode-width/0.1.6 \
    crate://crates.io/unicode-xid/0.1.0 \
    crate://crates.io/unicode-xid/0.2.0 \
    crate://crates.io/vec_map/0.8.1 \
    crate://crates.io/version_check/0.1.5 \
    crate://crates.io/wasi/0.10.0+wasi-snapshot-preview1 \
    crate://crates.io/winapi-i686-pc-windows-gnu/0.4.0 \
    crate://crates.io/winapi-x86_64-pc-windows-gnu/0.4.0 \
    crate://crates.io/winapi/0.3.8 \
"



# FIXME: update generateme with the real MD5 of the license file
LIC_FILES_CHKSUM = " \
    file://LICENSE;md5=c35dfce9b3e049acfe12832ce131f3db \
"

SUMMARY = "A simple CLI for editing and querying TOML files."
HOMEPAGE = "https://github.com/gnprice/toml-cli"
LICENSE = "MIT"

# includes this file if it exists but does not fail
# this is useful for anything you may want to override from
# what cargo-bitbake generates.
include toml-cli-${PV}.inc
include toml-cli.inc
