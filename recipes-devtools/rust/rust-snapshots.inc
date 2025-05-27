## This is information on the rust-snapshot (binary) used to build our current release.
## snapshot info is taken from rust/src/stage0.json
## Rust is self-hosting and bootstraps itself with a pre-built previous version of itself.
## The exact (previous) version that has been used is specified in the source tarball.
## The version is replicated here.
## TODO: find a way to add additional SRC_URIs based on the contents of an
##       earlier SRC_URI.
RS_VERSION = "1.86.0"
CARGO_VERSION = "1.86.0"

# TODO: Add hashes for other architecture toolchains as well. Make a script?
SRC_URI[rust-std-snapshot-x86_64.sha256sum] = "67be7184ea388d8ce0feaf7fdea46f1775cfc2970930264343b3089898501d37"
SRC_URI[rustc-snapshot-x86_64.sha256sum]    = "4438b809ce4a083af31ed17aeeedcc8fc60ccffc0625bef1926620751b6989d7"
SRC_URI[cargo-snapshot-x86_64.sha256sum]    = "c5c1590f7e9246ad9f4f97cfe26ffa92707b52a769726596a9ef81565ebd908b"

# currently we only build on x86 machines, we should groom this, as soon we support building on arch64 systems like mac

SRC_URI += " \
    https://static.rust-lang.org/dist/${RUST_STD_SNAPSHOT}.tar.xz;name=rust-std-snapshot-${RUST_BUILD_ARCH};subdir=rust-snapshot-components \
    https://static.rust-lang.org/dist/${RUSTC_SNAPSHOT}.tar.xz;name=rustc-snapshot-${RUST_BUILD_ARCH};subdir=rust-snapshot-components \
    https://static.rust-lang.org/dist/${CARGO_SNAPSHOT}.tar.xz;name=cargo-snapshot-${RUST_BUILD_ARCH};subdir=rust-snapshot-components \
"

RUST_STD_SNAPSHOT = "rust-std-${RS_VERSION}-${RUST_BUILD_ARCH}-unknown-linux-gnu"
RUSTC_SNAPSHOT = "rustc-${RS_VERSION}-${RUST_BUILD_ARCH}-unknown-linux-gnu"
CARGO_SNAPSHOT = "cargo-${CARGO_VERSION}-${RUST_BUILD_ARCH}-unknown-linux-gnu"
