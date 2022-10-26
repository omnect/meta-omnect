# overwrite LICENSE and LIC_FILES_CHKSUM from cargo-bitbake generated recipe
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=0f7e3b1308cb5c00b372a6e78835732d"

# overwrite CARGO_SRC_DIR from cargo-bitbake generated recipe
CARGO_SRC_DIR = "edgelet/iotedge"
CARGO_WORKSPACE_ROOT = "edgelet"

FILESEXTRAPATHS:prepend := "${THISDIR}/../:${LAYERDIR_omnect}/files/iotedge-patches:"

DEPENDS += "openssl"
RDEPENDS:${PN} += "iot-identity-service"

inherit features_check omnect_rust_iot-identity-service_deps

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

REQUIRED_DISTRO_FEATURES = "iotedge"
