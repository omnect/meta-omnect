LICENSE = "CLOSED"

SRC_URI = "git://dev.azure.com/conplementag/ICS_DeviceManagement/_git/bb-cplusplus-azure;protocol=https;branch=MVP;user=${ICS_DM_GIT_CREDENTIALS}"

python () {
    src_uri = d.getVar('ENROLLMENT_SERVICE_SRC_URI')
    if src_uri:
      d.setVar('SRC_URI', src_uri)
    else :
      src_uri = d.getVar('SRC_URI')
    if src_uri.startswith('file'):
      d.setVar('S',  d.getVar('WORKDIR') + "/service-enrollment")
    else :
      d.setVar('SRCREV', d.getVar('AUTOREV'))
      d.setVar('PV', '+git' + d.getVar('SRCPV'))
      d.setVar('S', d.getVar('WORKDIR') + "/git/service-enrollment")
}

DEPENDS = "azure-iot-sdk-c jq-native"
RDEPENDS_${PN} = "ca-certificates"

inherit cmake

EXTRA_OECMAKE += "-DBB_GITVERSION_INCLUDE_DIR=${BB_GIT_VERSION_INCLUDE_DIR}"
EXTRA_OECMAKE += "-DINSTALL_DIR=${bindir}"
EXTRA_OECMAKE += "-DSERVICE_INSTALL_DIR=${systemd_system_unitdir}"

inherit systemd

do_install_append() {
    install -d ${D}${sysconfdir}/ics_dm
    jq -n --arg dpsConnectionString "${ENROLLMENT_DPS_CONNECTION_STRING}" \
          --argjson edgeDevice "${IS_EDGE_DEVICE}" \
          --arg tag1 machine --arg tag1Value "${MACHINE}" \
          --arg tag2 tagName --arg tag2Value tagValue \
        '{ "dps_connectionString":"\($dpsConnectionString)",
           "edgeDevice": $edgeDevice,
           "tags" :
           { "\($tag1)" : "\($tag1Value)",
             "\($tag2)" : "\($tag2Value)"
        }}'  > ${D}${sysconfdir}/ics_dm/enrollment_static.conf
}
SYSTEMD_SERVICE_${PN} += "enrollment.service edge-provisioning.service"
FILES_${PN} += "${systemd_system_unitdir}"
REQUIRED_DISTRO_FEATURES = "systemd"
