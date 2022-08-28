require rust-sources.inc
require recipes-devtools/rust/libstd-rs.inc

# libstd moved from src/libstd to library/std in 1.47+
S = "${RUSTSRC}/library/std"

BBCLASSEXTEND = "nativesdk"
