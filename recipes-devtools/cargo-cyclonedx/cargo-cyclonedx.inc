# overwrite LICENSE and LIC_FILES_CHKSUM from cargo-bitbake generated recipe
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"

# Override cargo-bitbake's generated S = "${WORKDIR}/git", which oe-core's
# do_qa_unpack now rejects (git unpacks to ${UNPACKDIR}/${BP}).
S = "${UNPACKDIR}/${BP}"

BBCLASSEXTEND = "native nativesdk"
