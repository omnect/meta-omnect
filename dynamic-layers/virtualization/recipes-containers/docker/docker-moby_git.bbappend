do_install:append () {
    # install bash completion
    install -m 0644 -D ${S}/cli/contrib/completion/bash/docker ${D}/${datadir}/bash-completion/completions/docker
}
FILES:${PN} += "${datadir}/bash-completion/completions"
