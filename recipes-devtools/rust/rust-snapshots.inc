## This is information on the rust-snapshot (binary) used to build our current release.
## snapshot info is taken from rust/src/stage0.json
## Rust is self-hosting and bootstraps itself with a pre-built previous version of itself.
## The exact (previous) version that has been used is specified in the source tarball.
## The version is replicated here.
## TODO: find a way to add additional SRC_URIs based on the contents of an
##       earlier SRC_URI.
RS_VERSION = "1.73.0"
CARGO_VERSION = "1.73.0"

# TODO: Add hashes for other architecture toolchains as well. Make a script?
SRC_URI[rust-std-snapshot-x86_64.sha256sum] = "96efb163a57b400152c357be0ea3a0dd902b56cc0df662b9ac951403c7c7b15b"
SRC_URI[rustc-snapshot-x86_64.sha256sum] = "14f383eb4d6e65ce01cc99f2c5cf5a78744239f29704f72fe84f11095af779f5"
SRC_URI[cargo-snapshot-x86_64.sha256sum] = "7c3ce5738d570eaea97dd3d213ea73c8beda4f0c61e7486f95e497b7b10c4e2d"

# currently we only build on x86 machines, we should groom this, as soon we support building on arch65 systems like mac
# SRC_URI[rust-std-snapshot-aarch64.sha256sum] = "40abc9ec4f86ff0e37ba176e4c68dfa708e9857bb0372169c865367593127566"
# SRC_URI[rustc-snapshot-aarch64.sha256sum] = "8f10b379bcc8caaab983b7d04a3f105dae42f95718f231b46d7e68685d239191"
# SRC_URI[cargo-snapshot-aarch64.sha256sum] = "103d69e4f2f49f5a6309d7d195747b31f94cf707f90fb49cf76039a5ce6295c7"

SRC_URI += " \
    https://static.rust-lang.org/dist/${RUST_STD_SNAPSHOT}.tar.xz;name=rust-std-snapshot-${RUST_BUILD_ARCH};subdir=rust-snapshot-components \
    https://static.rust-lang.org/dist/${RUSTC_SNAPSHOT}.tar.xz;name=rustc-snapshot-${RUST_BUILD_ARCH};subdir=rust-snapshot-components \
    https://static.rust-lang.org/dist/${CARGO_SNAPSHOT}.tar.xz;name=cargo-snapshot-${RUST_BUILD_ARCH};subdir=rust-snapshot-components \
"

RUST_STD_SNAPSHOT = "rust-std-${RS_VERSION}-${RUST_BUILD_ARCH}-unknown-linux-gnu"
RUSTC_SNAPSHOT = "rustc-${RS_VERSION}-${RUST_BUILD_ARCH}-unknown-linux-gnu"
CARGO_SNAPSHOT = "cargo-${CARGO_VERSION}-${RUST_BUILD_ARCH}-unknown-linux-gnu"
