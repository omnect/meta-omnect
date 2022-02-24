SECTION = "kernel"

inherit allarch

LRD_LWB_URI_BASE = "https://github.com/LairdCP/Sterling-LWB-and-LWB5-Release-Packages/releases/download/LRD-REL-${PV}"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

FILES:${PN} += "${nonarch_base_libdir}/*"

S = "${WORKDIR}"

ALLOW_EMPTY:${PN}-dev = "0"
ALLOW_EMPTY:${PN}-dbg = "0"
