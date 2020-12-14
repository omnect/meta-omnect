#TODO adapt?
LICENSE = "CLOSED"

#TODO adapt to non dev branch
SRC_URI = "git://dev.azure.com/conplementag/ICS_DeviceManagement/_git/bb-cplusplus-azure;protocol=https;branch=marcel/feature/aduagent;user=${ICS_DM_GIT_CREDENTIALS}"
SRCREV = "${AUTOREV}"

DEPENDS = "azure-iot-sdk-c jq-native"
RDEPENDS_${PN} = "jq"

S = "${WORKDIR}/git/service-enrollment"

inherit cmake
EXTRA_OECMAKE += "-DINSTALL:DIR=bin"
EXTRA_OECMAKE += "-DBB_GITVERSION_INCLUDE_DIR=${BB_GIT_VERSION_INCLUDE_DIR}"
EXTRA_OECMAKE += "-DAZUREIOT_INCLUDE_DIR=/usr/include/azureiot"
EXTRA_OECMAKE += "-DINSTALL_DIR=${bindir}"

inherit systemd
do_install_append() {
    install -d ${D}${sysconfdir}/ics_dm
    jq -n --arg dpsConnectionString ${DPS_CONNECTION_STRING} \
          --arg edgeDevice ${IS_EDGE_DEVICE} \
          --arg tag1 machine --arg tag1Value ${MACHINE} \
          --arg tag2 tagName --arg tag2Value tagValue \
        '{ "dps_connectionString":"\($dpsConnectionString)",
           "edgeDevice":"\($edgeDevice)",
           "tags" :
           { "\($tag1)" : "\($tag1Value)",
             "\($tag2)" : "\($tag2Value)"
        }}'  > ${D}${sysconfdir}/ics_dm/enrollment_static.conf
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/systemd/enrollment.service  ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/systemd/pre-enrollment.service  ${D}${systemd_system_unitdir}
}
SYSTEMD_SERVICE_${PN} += "enrollment.service"
SYSTEMD_SERVICE_${PN} += "pre-enrollment.service"
FILES_${PN} += "${systemd_system_unitdir}/enrollment.service"
FILES_${PN} += "${systemd_system_unitdir}/pre-enrollment.service"

REQUIRED_DISTRO_FEATURES = "systemd"
