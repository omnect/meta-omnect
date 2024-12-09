FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://daemon.json \
"

do_install:append () {
    # install bash completion
    install -m 0644 -D ${S}/cli/contrib/completion/bash/docker ${D}/${datadir}/bash-completion/completions/docker

    install -m 0644 -D ${WORKDIR}/daemon.json ${D}${sysconfdir}/docker/daemon.json

    sed -i \
        -e 's/^After=\(.*\)$/After=\1 containerd.service/' \
        -e 's/^Wants=\(.*\)$/Wants=\1 containerd.service/' \
        ${D}/${systemd_unitdir}/system/docker.service
}

FILES:${PN} += " \
  ${datadir}/bash-completion/completions \
  ${sysconfdir}/docker/daemon.json \
  "
