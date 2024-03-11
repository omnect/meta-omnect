SUMMARY = "omnect Health Check"
DESCRIPTION = "Provide on-device files for run-time health checks."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "\
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
"

SRC_URI = "\
	file://lib.sh \
	file://omnect_service_log.sh \
	file://omnect_service_log.tmpfilesd \
	file://omnect_service_log_analyze.sh \
	file://omnect_service_log_analysis.json \
"

do_install() {
    # tpmfiles.d
    install -d ${D}${libdir}/tmpfiles.d

    # create tmpfiles.d entry to (re)create dir + permissions
    install -m 0644 -D ${WORKDIR}/omnect_service_log.tmpfilesd ${D}${libdir}/tmpfiles.d/omnect_service_log.conf

    # FIXME: the shell helper library should really be located somewhere else,
    #        probably all of the health check stuff shoul reside in a dedicated
    #        folder
    install -m 0755 -D ${WORKDIR}/lib.sh ${D}/${sbindir}/lib.sh
    install -m 0755 -D ${WORKDIR}/omnect_service_log.sh ${D}/${sbindir}/omnect_service_log.sh
    install -m 0755 -D ${WORKDIR}/omnect_service_log_analyze.sh ${D}/${sbindir}/omnect_service_log_analyze.sh

    install -m 0644 -D ${WORKDIR}/omnect_service_log_analysis.json ${D}/${sysconfdir}/omnect/health_check/omnect_service_log_analysis.json


}

FILES:${PN} = "\
	${sbindir}/lib.sh \
	${sbindir}/omnect_service_log.sh \
	${sbindir}/omnect_service_log_analyze.sh \
	${sysconfdir}/omnect/health_check/omnect_service_log_analysis.json \
	${libdir}/tmpfiles.d/omnect_service_log.conf \
"
