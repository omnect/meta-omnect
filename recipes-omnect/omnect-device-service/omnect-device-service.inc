FILESEXTRAPATHS:prepend := "${LAYERDIR_omnect}/files:${THISDIR}/${PN}:"

SRC_URI += "\
  file://iot-identity-service-keyd.template.toml \
  file://iot-identity-service-identityd.template.toml \
  file://omnect-device-service.tmpfilesd \
"

CVE_PRODUCT = "omnect:${PN}"

# we have to truncate ${PV}, it's to long for do_fetch
python() {
    pv = d.getVar('PV')
    pv = pv[:128]
    d.setVar('PV', pv)
}

# overwrite LICENSE and LIC_FILES_CHKSUM from cargo-bitbake generated recipe
LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://LICENSE-APACHE;md5=5382c4e117e2483c68e932fd10c4fd48 \
    file://LICENSE-MIT;md5=6340606a960b1965e521043f21f8d1bb \
"

DEPENDS += "\
    ${@bb.utils.contains('MACHINE_FEATURES', '3g', 'modemmanager', '', d)} \
    azure-iot-sdk-c \
    pkgconfig-native \
"

RDEPENDS:${PN} += "\
    aziot-identityd \
    bash \
    ca-certificates \
    polkit \
    sudo \
"
RDEPENDS:${PN}:append:omnect_grub = " grub-editenv"
RDEPENDS:${PN}:append:omnect_uboot = " u-boot-fw-utils"

inherit omnect-device-service omnect_rust_aziot-identityd_deps omnect_rust_azure-iot-sdk_deps systemd

CARGO_BUILD_FLAGS:append:omnect_grub = " --features=bootloader_grub"
CARGO_BUILD_FLAGS:append:omnect_uboot = " --features=bootloader_uboot"
CARGO_BUILD_FLAGS:append = "${@bb.utils.contains('MACHINE_FEATURES', '3g', ',modem_info', '', d)}"

export SOCKET_DIR = "/run/aziot"

do_install:append() {
    install -m 0644 -D ${S}/systemd/omnect-device-service.service ${D}${systemd_system_unitdir}/omnect-device-service.service
    install -m 0644 -D ${S}/systemd/omnect-device-service.socket ${D}${systemd_system_unitdir}/omnect-device-service.socket
    install -m 0644 -D ${S}/systemd/omnect-device-service.timer ${D}${systemd_system_unitdir}/omnect-device-service.timer
    install -m 0755 -D ${S}/systemd/omnect-device-service.exec_stop_post.sh ${D}${bindir}/omnect-device-service.exec_stop_post.sh
    install -m 0644 -D ${S}/polkit/omnect-device-service.rules ${D}${datadir}/polkit-1/rules.d/omnect-device-service.rules
    install -m 0640 -D ${S}/sudo/omnect-device-service ${D}${sysconfdir}/sudoers.d/omnect-device-service

    # allow omnect-device-service access to device_id secret created by manual provisioning
    install -m 0600 -o aziotks -g aziotks ${WORKDIR}/iot-identity-service-keyd.template.toml ${D}${sysconfdir}/aziot/keyd/config.d/omnect-device-service.toml

    # allow omnect-device-service provisioning via module identity
    install -m 0600 -o aziotid -g aziotid ${WORKDIR}/iot-identity-service-identityd.template.toml ${D}${sysconfdir}/aziot/identityd/config.d/omnect-device-service.toml

    # create tmpfiles.d entry to (re)create dir + permissions
    install -m 0644 -D ${WORKDIR}/omnect-device-service.tmpfilesd ${D}${libdir}/tmpfiles.d/omnect-device-service.conf
}

# health-check stuff
do_install:append() {
    # FIXME: the shell helper library should really be located somewhere else,
    #        probably all of the health check stuff shoul reside in a dedicated
    #        folder
    install -m 0755 -D ${S}/healthcheck/healthchecklib.sh                ${D}/${sbindir}/healthchecklib.sh
    install -m 0755 -D ${S}/healthcheck/omnect_health_check.sh           ${D}/${sbindir}/omnect_health_check.sh
    install -m 0755 -D ${S}/healthcheck/omnect_health__coredumps.sh      ${D}/${sbindir}/omnect_health__coredumps.sh
    install -m 0755 -D ${S}/healthcheck/omnect_health__services.sh       ${D}/${sbindir}/omnect_health__services.sh
    install -m 0755 -D ${S}/healthcheck/omnect_health__system_running.sh ${D}/${sbindir}/omnect_health__system_running.sh
    install -m 0755 -D ${S}/healthcheck/omnect_health__timesync.sh       ${D}/${sbindir}/omnect_health__timesync.sh
    install -m 0755 -D ${S}/healthcheck/omnect_service_log.sh            ${D}/${sbindir}/omnect_service_log.sh
    # and here the configuration files
    install -m 0644 -D ${S}/healthcheck/omnect_service_log_analysis.json ${D}/${sysconfdir}/omnect/health_check/omnect_service_log_analysis.json
    install -m 0644 -D ${S}/healthcheck/omnect_health_checks.json ${D}/${sysconfdir}/omnect/health_check/omnect_health_checks.json
}

do_install:append:omnect_grub() {
    install -m 0640 -D ${S}/sudo/omnect-device-service-grub ${D}${sysconfdir}/sudoers.d/omnect-device-service-bootloader-env
}

do_install:append:omnect_uboot() {
    install -m 0640 -D ${S}/sudo/omnect-device-service-uboot ${D}${sysconfdir}/sudoers.d/omnect-device-service-bootloader-env
}

pkg_postinst:${PN}() {
    sed -i    "s/@@UID@@/$(id -u omnect_device_service)/"                                           $D${sysconfdir}/aziot/keyd/config.d/omnect-device-service.toml
    sed -i -e "s/@@UID@@/$(id -u omnect_device_service)/" -e "s/@@NAME@@/omnect-device-service/"    $D${sysconfdir}/aziot/identityd/config.d/omnect-device-service.toml
}

SYSTEMD_SERVICE:${PN} = " \
    omnect-device-service.service \
    omnect-device-service.socket \
    omnect-device-service.timer \
"

FILES:${PN} += "\
    ${bindir}/omnect-device-service.exec_stop_post.sh \
    ${datadir}/polkit-1/rules.d/omnect-device-service.rules \
    ${libdir}/tmpfiles.d/omnect-device-service.conf \
    ${sysconfdir}/sudoers.d/omnect-device-service \
    ${sysconfdir}/sudoers.d/omnect-device-service-bootloader-env \
"

# health-check stuff
FILES:${PN} += "\
	${sbindir}/healthchecklib.sh \
	${sbindir}/omnect_health_check.sh \
	${sbindir}/omnect_health__coredumps.sh \
	${sbindir}/omnect_health__services.sh \
	${sbindir}/omnect_health__system_running.sh \
	${sbindir}/omnect_health__timesync.sh \
	${sbindir}/omnect_service_log.sh \
	${sysconfdir}/omnect/health_check/omnect_service_log_analysis.json \
	${sysconfdir}/omnect/health_check/omnect_health_checks.json \
"
