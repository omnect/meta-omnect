## This is information on the rust-snapshot (binary) used to build our current release.
## snapshot info is taken from rust/src/stage0.json
## Rust is self-hosting and bootstraps itself with a pre-built previous version of itself.
## The exact (previous) version that has been used is specified in the source tarball.
## The version is replicated here.
## TODO: find a way to add additional SRC_URIs based on the contents of an
##       earlier SRC_URI.
RS_VERSION = "1.74.0"
CARGO_VERSION = "1.74.0"

# TODO: Add hashes for other architecture toolchains as well. Make a script?
SRC_URI[rust-std-snapshot-x86_64.sha256sum] = "548413213012e2f62b08ed8a913a51210ae7402619027224580176031f2789ea"
SRC_URI[rustc-snapshot-x86_64.sha256sum] = "7d464be2ae0d6ce69f056d1ea9a8ce2b3b1d537418caea216fdd303903972181"
SRC_URI[cargo-snapshot-x86_64.sha256sum] = "f219386d4569c40b660518e99267afff428c13bf980bda7a614c8d4038d013f6"

# currently we only build on x86 machines, we should groom this, as soon we support building on arch64 systems like mac

SRC_URI += " \
    https://static.rust-lang.org/dist/${RUST_STD_SNAPSHOT}.tar.xz;name=rust-std-snapshot-${RUST_BUILD_ARCH};subdir=rust-snapshot-components \
    https://static.rust-lang.org/dist/${RUSTC_SNAPSHOT}.tar.xz;name=rustc-snapshot-${RUST_BUILD_ARCH};subdir=rust-snapshot-components \
    https://static.rust-lang.org/dist/${CARGO_SNAPSHOT}.tar.xz;name=cargo-snapshot-${RUST_BUILD_ARCH};subdir=rust-snapshot-components \
"

RUST_STD_SNAPSHOT = "rust-std-${RS_VERSION}-${RUST_BUILD_ARCH}-unknown-linux-gnu"
RUSTC_SNAPSHOT = "rustc-${RS_VERSION}-${RUST_BUILD_ARCH}-unknown-linux-gnu"
CARGO_SNAPSHOT = "cargo-${CARGO_VERSION}-${RUST_BUILD_ARCH}-unknown-linux-gnu"
