# Override cargo-bitbake's generated S = "${WORKDIR}/git", which oe-core's
# do_qa_unpack now rejects (git unpacks to ${UNPACKDIR}/${BP}).
S = "${UNPACKDIR}/${BP}"
