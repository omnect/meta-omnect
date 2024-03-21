CARGO_NET_OFFLINE ?= "true"

verify_frozen() {
    cd ${S}/${CARGO_WORKSPACE_ROOT}; cargo verify-project --frozen || bberror "Cargo.lock not uptodate"
}

do_configure:prepend() {
    verify_frozen

    # patch
    marker="# omnect_rust_modemmanager_deps.bbclass:"
    if [ -z "$(grep "${marker}" "${S}/${CARGO_WORKSPACE_ROOT}/Cargo.toml")" ]; then

cat <<EOF >> "${S}/${CARGO_WORKSPACE_ROOT}/Cargo.toml"

${marker}
[patch.'https://github.com/omnect/modemmanager.git']
modemmanager = { path = "${WORKDIR}/modemmanager" }

[patch.'https://github.com/omnect/modemmanager-sys.git']
modemmanager-sys = { path = "${WORKDIR}/modemmanager-sys" }
EOF
    fi
}

do_compile:prepend() {
    export LLVM_CONFIG_PATH="${STAGING_LIBDIR_NATIVE}/llvm-rust/bin/llvm-config"
    export BINDGEN_EXTRA_CLANG_ARGS="${TUNE_CCARGS}"
}
