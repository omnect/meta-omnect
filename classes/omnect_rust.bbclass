CARGO_NET_OFFLINE ?= "true"

verify_frozen() {
    cd ${S}/${CARGO_WORKSPACE_ROOT}; cargo verify-project --frozen || bberror "Cargo.lock not uptodate"
}

do_configure:prepend() {
    verify_frozen
}
