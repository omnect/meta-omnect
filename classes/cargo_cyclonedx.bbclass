DEPENDS += "cargo-cyclonedx-native"
inherit deploy

do_cyclonedx() {
    if [ -n "${CARGO_FEATURES}" ]; then
        CYCLONEDX_FEATURES="--features ${CARGO_FEATURES}"
    fi
    cd ${WORKDIR}
    ${STAGING_BINDIR_NATIVE}/cargo-cyclonedx cyclonedx --manifest-path ${MANIFEST_PATH} ${CYCLONEDX_FEATURES} --target ${RUST_TARGET_SYS} --spec-version 1.5 --format json
}
do_cyclonedx[network] = "1"

do_deploy() {
    cp ${S}/${CARGO_SRC_DIR}/${PN}.cdx.json ${DEPLOYDIR}/
}

addtask do_cyclonedx after do_compile before do_deploy
addtask do_deploy after do_cyclonedx before do_build