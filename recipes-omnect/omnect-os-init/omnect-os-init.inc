CARGO_BUILD_FLAGS .= " --features=ptable_${OMNECT_PART_TYPE}"

LICENSE = "MIT | Apache-2.0"

LIC_FILES_CHKSUM = "\
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"

do_install:append() {
    mv ${D}/usr/bin/omnect-os-init ${D}/init
    rmdir ${D}/usr/bin
}
FILES:${PN} += "init"