LICENSE = "MIT | Apache-2.0"

LIC_FILES_CHKSUM="\
  file://LICENSE-MIT;md5=afb814368d9110052a22e0da67f027d3 \
  file://LICENSE-APACHE;md5=650e893673eb59696f3d4ee64f6d2357 \
"

# TODO change to https uri when public
SRCREV = "0a83cfee14d7fc214a89fb0bcebb086870246702"
REPO_URI = "git://git@github.com/JanZachmann/enrollment.git;protocol=ssh;branch=rename-to-omnect;"
SRC_URI = "${REPO_URI}"
PV = "${SRCPV}"

S = "${WORKDIR}/git"

DEPENDS = "azure-iot-sdk-c-prov"
RDEPENDS:${PN} = " \
  ${@bb.utils.contains('DISTRO_FEATURES', 'iotedge', 'iotedge', '', d)} \
  bash \
  toml-cli \
  ca-certificates \
  jq \
  iot-identity-service \
"

inherit cmake features_check overwrite_src_uri

PACKAGECONFIG ??="\
  ${@bb.utils.contains('DISTRO_FEATURES', 'iotedge', 'iotedge', '', d)}\
"
PACKAGECONFIG[iotedge] = "-DIOTEDGE:BOOL=ON,-DIOTEDGE:BOOL=OFF"

EXTRA_OECMAKE += "-DINSTALL_DIR=${bindir}"
EXTRA_OECMAKE += "-DSERVICE_INSTALL_DIR=${systemd_system_unitdir}"
EXTRA_OECMAKE += "-DDEVICE:BOOL=ON"
EXTRA_OECMAKE += "-DTPM_SIMULATOR:BOOL=OFF"
EXTRA_OECMAKE += "${@bb.utils.contains('MACHINE_FEATURES', 'tpm2', '-DTPM:BOOL=ON', '', d)}"

inherit useradd

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM:${PN} = " \
  -r aziot; \
  -r enrollment; \
  -r tpm \
"
USERADD_PARAM:${PN} = "--no-create-home -r -s /bin/false -g enrollment -G aziot,tpm enrollment"

inherit systemd

do_install:append() {
    install -d ${D}${sysconfdir}/omnect
    chgrp enrollment ${D}${sysconfdir}/omnect
    chmod g+rw ${D}${sysconfdir}/omnect

    # create tmpfiles.d entry to (re)create permissions
    install -d ${D}${libdir}/tmpfiles.d
    echo "z  0775 root enrollment -"                        >> ${D}${libdir}/tmpfiles.d/enrollment.conf
    echo "z /enrollment_static.json 0664 root enrollment -" >> ${D}${libdir}/tmpfiles.d/enrollment.conf

    install -m 755 ${S}/scripts/patch_config_toml.sh ${D}${bindir}/

    install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants
    ln -rs ${D}${systemd_system_unitdir}/enrollment-patch-config-toml@.service ${D}${sysconfdir}/systemd/system/multi-user.target.wants/enrollment-patch-config-toml@${ICS_DM_ETH0}.service
}

SYSTEMD_SERVICE:${PN} = "enrollment-config-apply.path enrollment.service"
FILES:${PN} += "\
  ${libdir}/tmpfiles.d/enrollment.conf \
  ${systemd_system_unitdir} \
"
REQUIRED_DISTRO_FEATURES = "systemd"
