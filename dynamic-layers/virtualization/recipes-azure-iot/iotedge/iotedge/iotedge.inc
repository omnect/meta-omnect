# overwrite LIC_FILES_CHKSUM from cargo-bitbake generated recipe
LIC_FILES_CHKSUM = "file://LICENSE;md5=0f7e3b1308cb5c00b372a6e78835732d"

# overwrite CARGO_SRC_DIR from cargo-bitbake generated recipe
CARGO_SRC_DIR = "edgelet/iotedge"
CARGO_LOCK_PATH = "${S}/edgelet/Cargo.lock"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}/:"

SRC_URI += "\
  file://apply_doesnt_restart_services.patch \
  file://fix_compiler_toolchain_1.8x.patch \
  file://fix_warnings_aziot-cert-client-async.patch;patchdir=${WORKDIR}/aziot-cert-client-async \
"

DEPENDS += "openssl"
RDEPENDS:${PN} += "aziot-identityd"

inherit features_check omnect_rust_aziot-identityd_deps

export OPENSSL_DIR = "${STAGING_EXECPREFIXDIR}"
export IOTEDGE_CONNECT_MANAGEMENT_URI = "unix:///var/run/iotedge/mgmt.sock"
export IOTEDGE_CONNECT_WORKLOAD_URI = "unix:///var/run/iotedge/workload.sock"
export IOTEDGE_LISTEN_MANAGEMENT_URI = "fd://aziot-edged.mgmt.socket"
export IOTEDGE_LISTEN_WORKLOAD_URI = "fd://aziot-edged.workload.socket"
export SOCKET_DIR = "/run/aziot"

RUSTFLAGS+="-D warnings"

do_install () {
    # Binaries
    install -d  "${D}${bindir}"
    install -m 755 "${WORKDIR}/build/target/${CARGO_TARGET_SUBDIR}/iotedge" ${D}${bindir}/iotedge
}

REQUIRED_DISTRO_FEATURES = "iotedge"
