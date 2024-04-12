SUMMARY = "omnect Health Check"
DESCRIPTION = "Provide on-device files for run-time health checks."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "\
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
"

SRC_URI = "\
	file://lib.sh \
	file://omnect_health__coredumps.sh \
	file://omnect_health__services.sh \
	file://omnect_health__system_running.sh \
	file://omnect_health__timesync.sh \
	file://omnect_health_check.sh \
	file://omnect_health_checks.json \
	file://omnect_service_log.sh \
	file://omnect_service_log.tmpfilesd \
	file://omnect_service_log_analysis.json \
"

RDEPENDS:${PN} = "bash"

do_install() {
    # tpmfiles.d
    install -d ${D}${libdir}/tmpfiles.d

    # create tmpfiles.d entry to (re)create dir + permissions
    install -m 0644 -D ${WORKDIR}/omnect_service_log.tmpfilesd     ${D}${libdir}/tmpfiles.d/omnect_service_log.conf

    # FIXME: the shell helper library should really be located somewhere else,
    #        probably all of the health check stuff shoul reside in a dedicated
    #        folder
    install -m 0755 -D ${WORKDIR}/lib.sh                           ${D}/${sbindir}/lib.sh
    install -m 0755 -D ${WORKDIR}/omnect_health_check.sh           ${D}/${sbindir}/omnect_health_check.sh
    install -m 0755 -D ${WORKDIR}/omnect_health__coredumps.sh      ${D}/${sbindir}/omnect_health__coredumps.sh
    install -m 0755 -D ${WORKDIR}/omnect_health__services.sh       ${D}/${sbindir}/omnect_health__services.sh
    install -m 0755 -D ${WORKDIR}/omnect_health__system_running.sh ${D}/${sbindir}/omnect_health__system_running.sh
    install -m 0755 -D ${WORKDIR}/omnect_health__timesync.sh       ${D}/${sbindir}/omnect_health__timesync.sh
    install -m 0755 -D ${WORKDIR}/omnect_service_log.sh            ${D}/${sbindir}/omnect_service_log.sh

    install -m 0644 -D ${WORKDIR}/omnect_service_log_analysis.json ${D}/${sysconfdir}/omnect/health_check/omnect_service_log_analysis.json
    install -m 0644 -D ${WORKDIR}/omnect_health_checks.json ${D}/${sysconfdir}/omnect/health_check/omnect_health_checks.json
}

FILES:${PN} = "\
	${sbindir}/lib.sh \
	${sbindir}/omnect_health_check.sh \
	${sbindir}/omnect_health__coredumps.sh \
	${sbindir}/omnect_health__services.sh \
	${sbindir}/omnect_health__system_running.sh \
	${sbindir}/omnect_health__timesync.sh \
	${sbindir}/omnect_service_log.sh \
	${sysconfdir}/omnect/health_check/omnect_service_log_analysis.json \
	${sysconfdir}/omnect/health_check/omnect_health_checks.json \
	${libdir}/tmpfiles.d/omnect_service_log.conf \
"
