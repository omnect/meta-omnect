PROVIDES = "virtual/bootloader"
PKGV = "${PV}-0"

do_deploy:append() {
    mkdir -p ${DEPLOYDIR}
    echo "${PKGV}" > ${DEPLOYDIR}/bootloader_version
}
