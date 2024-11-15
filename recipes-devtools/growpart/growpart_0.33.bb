SUMMARY = "tool to resize a partition of an image"
LICENSE = "GPL-3.0-only"

LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=d32239bcb673463ab874e80d47fae504"

SRC_URI = " \
    https://raw.githubusercontent.com/canonical/cloud-utils/${PV}/bin/growpart;md5sum=9774d13f0af07738747f5a3f1c33071d \
    https://raw.githubusercontent.com/canonical/cloud-utils/${PV}/LICENSE;md5sum=d32239bcb673463ab874e80d47fae504 \
"

RDEPENDS:${PN} = " \
    gawk \
    sed \
    util-linux-flock \
    util-linux-sfdisk \
"

do_install() {
    install -m 0755 -D ${WORKDIR}/growpart ${D}/${bindir}/growpart
}

FILES:${PN} = "${bindir}/growpart"
