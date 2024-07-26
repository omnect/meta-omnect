FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://daemon.json \
    file://0001-daemon-overlay2-Write-layer-metadata-atomically.patch \
"

do_install:append () {
    # install bash completion
    install -m 0644 -D ${S}/cli/contrib/completion/bash/docker ${D}/${datadir}/bash-completion/completions/docker

    install -m 0644 -D ${WORKDIR}/daemon.json ${D}${sysconfdir}/docker/daemon.json
}

FILES:${PN} += " \
  ${datadir}/bash-completion/completions \
  ${sysconfdir}/docker/daemon.json \
  "
