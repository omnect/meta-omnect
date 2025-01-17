# overwrite LIC_FILES_CHKSUM from cargo-bitbake generated recipe
LIC_FILES_CHKSUM = "file://LICENSE;md5=0f7e3b1308cb5c00b372a6e78835732d"

SRC_URI += "\
  file://fix_compiler_toolchain_1.8x.patch \
  file://fix_warnings_aziot-cert-client-async.patch;patchdir=${WORKDIR}/aziot-cert-client-async \
"

# overwrite CARGO_SRC_DIR from cargo-bitbake generated recipe
CARGO_SRC_DIR = "edgelet/aziot-edged"
CARGO_LOCK_PATH = "${S}/edgelet/Cargo.lock"

DEPENDS += "openssl virtual/docker"
RDEPENDS:${PN} += "aziot-identityd docker"

export OPENSSL_DIR = "${STAGING_EXECPREFIXDIR}"
export IOTEDGE_CONNECT_MANAGEMENT_URI = "unix:///var/run/iotedge/mgmt.sock"
export IOTEDGE_CONNECT_WORKLOAD_URI = "unix:///var/run/iotedge/workload.sock"
export IOTEDGE_LISTEN_MANAGEMENT_URI = "fd://aziot-edged.mgmt.socket"
export IOTEDGE_LISTEN_WORKLOAD_URI = "fd://aziot-edged.workload.socket"
export SOCKET_DIR = "/run/aziot"

inherit aziot features_check omnect_rust_aziot-identityd_deps systemd

RUSTFLAGS+="-D warnings"

do_install () {
    # binaries
    install -d -m 0750 -g aziot ${D}${libexecdir}/aziot
    install -m 0750 -o iotedge -g iotedge ${WORKDIR}/build/target/${CARGO_TARGET_SUBDIR}/aziot-edged ${D}${libexecdir}/aziot/aziot-edged

    # home
    install -d -m 0700 -o iotedge -g iotedge ${D}${localstatedir}/lib/aziot/edged
    install -d ${D}${libdir}/tmpfiles.d
    echo "d ${localstatedir}/lib/aziot/edged 0700 iotedge iotedge -"  >> ${D}${libdir}/tmpfiles.d/aziot-edged.conf
    echo "d /run/iotedge 0755 iotedge iotedge -" >> ${D}${libdir}/tmpfiles.d/aziot-edged.conf

    # config files
    install -m 0640 ${S}/edgelet/contrib/config/linux/template.toml ${D}${sysconfdir}/aziot/config.toml.edge.template
    sed -i -e "s#@connect_workload_uri@#${IOTEDGE_CONNECT_WORKLOAD_URI}#" \
        -e "s#@connect_management_uri@#${IOTEDGE_CONNECT_MANAGEMENT_URI}#" \
        -e "s#@listen_workload_uri@#${IOTEDGE_LISTEN_WORKLOAD_URI}#" \
        -e "s#@listen_management_uri@#${IOTEDGE_LISTEN_MANAGEMENT_URI}#" \
        ${D}${sysconfdir}/aziot/config.toml.edge.template

    install -d -m 0700 -o iotedge -g iotedge ${D}${sysconfdir}/aziot/edged/config.d
    install -m 0640 ${S}/edgelet/contrib/config/linux/default.toml ${D}${sysconfdir}/aziot/edged/config.toml.default
    sed -i -e "s#@connect_workload_uri@#${IOTEDGE_CONNECT_WORKLOAD_URI}#" \
        -e "s#@connect_management_uri@#${IOTEDGE_CONNECT_MANAGEMENT_URI}#" \
        -e "s#@listen_workload_uri@#${IOTEDGE_LISTEN_WORKLOAD_URI}#" \
        -e "s#@listen_management_uri@#${IOTEDGE_LISTEN_MANAGEMENT_URI}#" \
        ${D}${sysconfdir}/aziot/edged/config.toml.default

    # systemd services and sockets
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/edgelet/contrib/systemd/debian/aziot-edged.service  ${D}${systemd_system_unitdir}/aziot-edged.service
    sed -i 's/^After=\(.*\)$/After=\1 etc.mount var-lib.mount systemd-tmpfiles-setup.service/' ${D}${systemd_system_unitdir}/aziot-edged.service
    sed -i -e 's#^After=\(.*\)$#After=\1\nConditionPathExists=/etc/aziot/config.toml\nConditionPathExists=/etc/aziot/identityd/config.d/00-super.toml#' ${D}${systemd_system_unitdir}/aziot-edged.service \
	-e 's#^ExecStart=\(.*\)$#ExecStartPre=+-bash -c "/usr/sbin/omnect_service_log.sh start aziot-edged"\nExecStart=\1\nExecStopPost=+-/bin/sh -c "/usr/sbin/omnect_service_log.sh stop aziot-edged \\"$$SERVICE_RESULT\\" \\"$$EXIT_CODE\\" \\"$$EXIT_STATUS\\""#' \

    install -m 0644 ${S}/edgelet/contrib/systemd/debian/aziot-edged.workload.socket  ${D}${systemd_system_unitdir}/aziot-edged.workload.socket
    install -m 0644 ${S}/edgelet/contrib/systemd/debian/aziot-edged.mgmt.socket  ${D}${systemd_system_unitdir}/aziot-edged.mgmt.socket
}

USERADD_PARAM:${PN} += " \
    -r -u 15580 -g iotedge -G aziot,aziotcs,aziotid,aziotks,docker,systemd-journal -s /bin/false -d ${localstatedir}/lib/iotedge iotedge; \
    -r -g iotedge -s /sbin/false -M edgeagentuser; \
"

GROUPADD_PARAM:${PN} += " \
    -r docker; \
    -r -g 15580 iotedge; \
    -r systemd-journal; \
"

FILES:${PN} += " \
    ${libdir}/tmpfiles.d/aziot-edged.conf \
    ${localstatedir}/lib/aziot/edged \
    ${systemd_system_unitdir}/* \
"

SYSTEMD_SERVICE:${PN} = "aziot-edged.service aziot-edged.mgmt.socket aziot-edged.workload.socket"

REQUIRED_DISTRO_FEATURES = "iotedge"
