FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = "\
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"

SRC_URI = " \
    file://expand-data.service \
    file://expand-data.sh \
"

S = "${WORKDIR}"

RDEPENDS_${PN} = "\
    bash \
    e2fsprogs-e2fsck \
    e2fsprogs-resize2fs \
    parted \
"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/expand-data.sh ${D}${bindir}
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/expand-data.service ${D}${systemd_system_unitdir}
}

FILES_${PN} = "${bindir}/expand-data.sh ${systemd_system_unitdir}/expand-data.service"

REQUIRED_DISTRO_FEATURES = "systemd"
inherit allarch features_check systemd
SYSTEMD_SERVICE_${PN} = "expand-data.service"
