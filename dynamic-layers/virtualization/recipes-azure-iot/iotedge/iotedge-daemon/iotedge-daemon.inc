DEPENDS += "openssl virtual/docker"
RDEPENDS_${PN} += "docker iot-identity-service"
INSANE_SKIP_${PN} += "dev-deps"

PACKAGECONFIG ??= "${@bb.utils.contains('DISTRO_FEATURES', 'ics-dm-demo', 'ics-dm-demo', '', d)}"
PACKAGECONFIG[ics-dm-demo] = ""

export OPENSSL_DIR = "${STAGING_EXECPREFIXDIR}"
export IOTEDGE_CONNECT_MANAGEMENT_URI = "unix:///var/run/iotedge/mgmt.sock"
export IOTEDGE_CONNECT_WORKLOAD_URI = "unix:///var/run/iotedge/workload.sock"
export IOTEDGE_LISTEN_MANAGEMENT_URI = "fd://aziot-edged.mgmt.socket"
export IOTEDGE_LISTEN_WORKLOAD_URI = "fd://aziot-edged.workload.socket"

inherit aziot features_check systemd

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
    sed -i 's#^After=\(.*\)$#After=\1\nConditionPathExists=/etc/aziot/config.toml\nConditionPathExists=/etc/aziot/identityd/config.d/00-super.toml#' ${D}${systemd_system_unitdir}/aziot-edged.service
    if ${@bb.utils.contains('PACKAGECONFIG', 'ics-dm-demo', 'true', 'false', d)}; then
        sed -i 's#^After=\(.*\)$#After=\1\nConditionPathExists=/etc/ics_dm/enrolled#' ${D}${systemd_system_unitdir}/aziot-edged.service
    fi
    install -m 0644 ${S}/edgelet/contrib/systemd/debian/aziot-edged.workload.socket  ${D}${systemd_system_unitdir}/aziot-edged.workload.socket
    install -m 0644 ${S}/edgelet/contrib/systemd/debian/aziot-edged.mgmt.socket  ${D}${systemd_system_unitdir}/aziot-edged.mgmt.socket
}

USERADD_PARAM_${PN} += "-r -u 15580 -g iotedge -G aziot,aziotcs,aziotid,aziotks,docker,systemd-journal -s /bin/false -d ${localstatedir}/lib/iotedge iotedge;"

GROUPADD_PARAM_${PN} += " \
    -r docker; \
    -r -g 15580 iotedge; \
    -r systemd-journal; \
"

FILES_${PN} += " \
    ${libdir}/tmpfiles.d/aziot-edged.conf \
    ${localstatedir}/lib/aziot/edged \
    ${systemd_system_unitdir}/* \
"

SYSTEMD_SERVICE_${PN} = "aziot-edged.service aziot-edged.mgmt.socket aziot-edged.workload.socket"

REQUIRED_DISTRO_FEATURES = "iotedge"
