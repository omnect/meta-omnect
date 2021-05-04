inherit cargo

LICENSE = "MPL-2.0"

CARGO_DISABLE_BITBAKE_VENDORING = "1"

do_compile() {
    oe_cargo_fix_env
    export RUSTFLAGS="${RUSTFLAGS}"
	export RUST_TARGET_PATH="${RUST_TARGET_PATH}"
    cargo install cbindgen --version 0.15.0 --locked
}

do_install() {
    install -d  "${D}${bindir}"
    install -m 755 "${CARGO_HOME}/bin/cbindgen" ${D}${bindir}
}

BBCLASSEXTEND="native nativesdk"
