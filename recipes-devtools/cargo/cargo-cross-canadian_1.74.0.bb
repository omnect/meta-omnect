require ${LAYERDIR_core}/recipes-devtools/rust/rust-source.inc
require ${LAYERDIR_omnect}/recipes-devtools/rust/rust-source.inc
require ${LAYERDIR_omnect}/recipes-devtools/rust/rust-snapshots.inc

FILESEXTRAPATHS:prepend := "${THISDIR}/cargo-${PV}:"

require recipes-devtools/cargo/cargo-cross-canadian.inc
