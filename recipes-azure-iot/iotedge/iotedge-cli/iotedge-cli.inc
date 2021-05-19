FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://iotedge-cli_1.2.0.patch"

DEPENDS += "openssl"
RDEPENDS_${PN} += "iot-identity-service"

export OPENSSL_DIR = "${STAGING_EXECPREFIXDIR}"
export IOTEDGE_CONNECT_MANAGEMENT_URI = "unix:///var/run/iotedge/mgmt.sock"
export IOTEDGE_CONNECT_WORKLOAD_URI = "unix:///var/run/iotedge/workload.sock"
export IOTEDGE_LISTEN_MANAGEMENT_URI = "fd://aziot-edged.mgmt.socket"
export IOTEDGE_LISTEN_WORKLOAD_URI = "fd://aziot-edged.workload.socket"

do_install () {
    # Binaries
    install -d  "${D}${bindir}"
    install -m 755 "${WORKDIR}/build/target/${CARGO_TARGET_SUBDIR}/iotedge" ${D}${bindir}/iotedge
}
