require recipes-devtools/rust/rust-cross-canadian.inc
require rust-sources.inc
require rust-snapshots.inc

FILESEXTRAPATHS:prepend := "${THISDIR}/rust:"
