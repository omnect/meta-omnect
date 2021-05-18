inherit cargo


LICENSE = "BSD-3-Clause"

CARGO_DISABLE_BITBAKE_VENDORING = "1"

do_compile() {
    oe_cargo_fix_env
    export RUSTFLAGS="${RUSTFLAGS}"
    export RUST_TARGET_PATH="${RUST_TARGET_PATH}"

    export LLVM_CONFIG_PATH="${STAGING_LIBDIR_NATIVE}/llvm-rust/bin/llvm-config"
    cargo install bindgen --version 0.54.0 --locked
}

do_install() {
    install -d  "${D}${bindir}"
    install -m 755 "${CARGO_HOME}/bin/bindgen" ${D}${bindir}
}

BBCLASSEXTEND="native nativesdk"
