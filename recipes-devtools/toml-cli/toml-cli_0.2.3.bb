# Auto-Generated by cargo-bitbake 0.3.16
#
inherit cargo

# If this is git based prefer versioned ones if they exist
# DEFAULT_PREFERENCE = "-1"

# how to get toml-cli could be as easy as but default to a git checkout:
# SRC_URI += "crate://crates.io/toml-cli/0.2.3"
SRC_URI += "git://github.com/gnprice/toml-cli.git;protocol=https;nobranch=1"
SRCREV = "ea69e9d2ca4f0f858110dc7a5ae28bcb918c07fb"
S = "${WORKDIR}/git"
CARGO_SRC_DIR = ""


# please note if you have entries that do not begin with crate://
# you must change them to how that package can be fetched
SRC_URI += " \
    crate://crates.io/addr2line/0.17.0 \
    crate://crates.io/adler/1.0.2 \
    crate://crates.io/ansi_term/0.12.1 \
    crate://crates.io/atty/0.2.14 \
    crate://crates.io/autocfg/1.1.0 \
    crate://crates.io/backtrace/0.3.66 \
    crate://crates.io/bitflags/1.3.2 \
    crate://crates.io/bytes/1.3.0 \
    crate://crates.io/cc/1.0.77 \
    crate://crates.io/cfg-if/1.0.0 \
    crate://crates.io/clap/2.34.0 \
    crate://crates.io/combine/4.6.6 \
    crate://crates.io/either/1.8.0 \
    crate://crates.io/failure/0.1.8 \
    crate://crates.io/failure_derive/0.1.8 \
    crate://crates.io/fastrand/1.8.0 \
    crate://crates.io/gimli/0.26.2 \
    crate://crates.io/hashbrown/0.12.3 \
    crate://crates.io/heck/0.3.3 \
    crate://crates.io/hermit-abi/0.1.19 \
    crate://crates.io/indexmap/1.9.2 \
    crate://crates.io/instant/0.1.12 \
    crate://crates.io/itertools/0.10.5 \
    crate://crates.io/itoa/1.0.4 \
    crate://crates.io/lazy_static/1.4.0 \
    crate://crates.io/libc/0.2.137 \
    crate://crates.io/memchr/2.5.0 \
    crate://crates.io/minimal-lexical/0.2.1 \
    crate://crates.io/miniz_oxide/0.5.4 \
    crate://crates.io/nom/7.1.1 \
    crate://crates.io/object/0.29.0 \
    crate://crates.io/proc-macro-error-attr/1.0.4 \
    crate://crates.io/proc-macro-error/1.0.4 \
    crate://crates.io/proc-macro2/1.0.47 \
    crate://crates.io/quote/1.0.21 \
    crate://crates.io/redox_syscall/0.2.16 \
    crate://crates.io/remove_dir_all/0.5.3 \
    crate://crates.io/rustc-demangle/0.1.21 \
    crate://crates.io/ryu/1.0.11 \
    crate://crates.io/serde/1.0.148 \
    crate://crates.io/serde_json/1.0.89 \
    crate://crates.io/strsim/0.8.0 \
    crate://crates.io/structopt-derive/0.4.18 \
    crate://crates.io/structopt/0.3.26 \
    crate://crates.io/syn/1.0.105 \
    crate://crates.io/synstructure/0.12.6 \
    crate://crates.io/tempfile/3.3.0 \
    crate://crates.io/textwrap/0.11.0 \
    crate://crates.io/toml_datetime/0.5.0 \
    crate://crates.io/toml_edit/0.15.0 \
    crate://crates.io/unicode-ident/1.0.5 \
    crate://crates.io/unicode-segmentation/1.10.0 \
    crate://crates.io/unicode-width/0.1.10 \
    crate://crates.io/unicode-xid/0.2.4 \
    crate://crates.io/vec_map/0.8.2 \
    crate://crates.io/version_check/0.9.4 \
    crate://crates.io/winapi-i686-pc-windows-gnu/0.4.0 \
    crate://crates.io/winapi-x86_64-pc-windows-gnu/0.4.0 \
    crate://crates.io/winapi/0.3.9 \
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
