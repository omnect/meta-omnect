require recipes-devtools/rust/rust-cross-canadian.inc
require ${LAYERDIR_core}/recipes-devtools/rust/rust-source.inc
require rust-source.inc
require rust-snapshots.inc

FILESEXTRAPATHS:prepend := "${THISDIR}/rust:"
