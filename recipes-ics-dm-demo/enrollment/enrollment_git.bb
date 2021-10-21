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

DEPENDS = "azure-iot-sdk-c-prov"
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
    chgrp enrollment ${D}${sysconfdir}/ics_dm
    chmod g+rw ${D}${sysconfdir}/ics_dm

    install -m 755 ${S}/scripts/patch_config_toml.sh ${D}${bindir}/
}

do_install_append_rpi() {
    install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants
    lnr ${D}${systemd_system_unitdir}/enrollment-patch-config-toml@.service ${D}${sysconfdir}/systemd/system/multi-user.target.wants/enrollment-patch-config-toml@eth0.service
}

SYSTEMD_SERVICE_${PN} = "enrollment-config-apply.path enrollment.service enrolled.path"
FILES_${PN} += "${systemd_system_unitdir}"
REQUIRED_DISTRO_FEATURES = "systemd"
