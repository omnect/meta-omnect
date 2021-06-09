LICENSE = "MIT | Apache-2.0"

LIC_FILES_CHKSUM="\
  file://LICENSE-MIT;md5=afb814368d9110052a22e0da67f027d3 \
  file://LICENSE-APACHE;md5=650e893673eb59696f3d4ee64f6d2357 \
"

# TODO change to https uri when public
REPO_URI = "git://git@github.com/ICS-DeviceManagement/enrollment.git;protocol=ssh;branch=main"
SRC_URI = "${REPO_URI}"
SRCREV = "${AUTOREV}"

S = "${WORKDIR}/git"

DEPENDS = "azure-iot-sdk-c-prov jq-native"
RDEPENDS_${PN} = "ca-certificates jq"

inherit cmake features_check overwrite_src_uri

PACKAGECONFIG ??="\
  ${@bb.utils.contains('DISTRO_FEATURES', 'iotedge', 'iotedge', '', d)}\
  ${@bb.utils.contains('DISTRO_FEATURES', 'tpm', 'tpm', '', d)}\
"
PACKAGECONFIG[iotedge] = "-DIOTEDGE:BOOL=ON,-DIOTEDGE:BOOL=OFF"
PACKAGECONFIG[tpm] = "-DTPM:BOOL=ON,-DTPM:BOOL=OFF"

EXTRA_OECMAKE += "-DINSTALL_DIR=${bindir}"
EXTRA_OECMAKE += "-DSERVICE_INSTALL_DIR=${systemd_system_unitdir}"
EXTRA_OECMAKE += "-DDEVICE:BOOL=ON"
EXTRA_OECMAKE += "-DTPM_SIMULATOR:BOOL=OFF"

inherit useradd

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM_${PN} = " \
  -r aziot; \
  -r enrollment; \
  -r tpm \
"
USERADD_PARAM_${PN} = "--no-create-home -r -s /bin/false -g enrollment -G aziot,tpm enrollment"

inherit systemd

do_install_append() {
    install -d ${D}${sysconfdir}/ics_dm
    jq -n --arg dpsConnectionString "${ENROLLMENT_DPS_CONNECTION_STRING}" \
          --argjson edgeDevice "${@bb.utils.contains('DISTRO_FEATURES', 'iotedge', 'true', 'false', d)}" \
          --arg tag1 machine --arg tag1Value "${MACHINE}" \
          --arg tag2 ADUGroup --arg tag2Value "${ADU_GROUP}" \
        '{ "dps_connectionString":"\($dpsConnectionString)",
           "edgeDevice": $edgeDevice,
           "tags" :
           { "\($tag1)" : "\($tag1Value)",
             "\($tag2)" : "\($tag2Value)"
        }}'  > ${D}${sysconfdir}/ics_dm/enrollment_static.conf

    jq -n --arg provisioningGlobalEndpoint "${DPS_ENDPOINT}" \
          --arg provisioningScopeId "${DPS_SCOPE_ID}" \
        '{ "provisioning_global_endpoint":"\($provisioningGlobalEndpoint)",
           "provisioning_scope_id":"\($provisioningScopeId)" }'  > ${D}${sysconfdir}/ics_dm/provisioning_static.conf

    install -m 755 ${S}/scripts/iot_identity_provisioning.sh ${D}${bindir}/

    chgrp enrollment ${D}${sysconfdir}/ics_dm
    chmod g+rw ${D}${sysconfdir}/ics_dm
}
SYSTEMD_SERVICE_${PN} = "enrollment-config-apply.path enrollment.service enrolled.path"
FILES_${PN} += "${systemd_system_unitdir}"
REQUIRED_DISTRO_FEATURES = "systemd"
