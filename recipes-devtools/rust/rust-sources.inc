SRC_URI += "https://static.rust-lang.org/dist/rustc-${PV}-src.tar.xz;name=rust"
SRC_URI[rust.sha256sum] = "02066a93c2f6596cc046a897d5716c86e3607c1cd0f54db9a867ae8c8265072e"

#SRC_URI:append:class-target:pn-rust = " file://hardcodepaths.patch"
#SRC_URI:append:class-nativesdk:pn-nativesdk-rust = " file://hardcodepaths.patch"
SRC_URI:append:pn-rust-llvm-native = " file://0003-llvm-fix-include-benchmarks.patch;striplevel=2"

RUSTSRC = "${WORKDIR}/rustc-${PV}-src"

UPSTREAM_CHECK_URI = "https://forge.rust-lang.org/infra/other-installation-methods.html"
UPSTREAM_CHECK_REGEX = "rustc-(?P<pver>\d+(\.\d+)+)-src"
