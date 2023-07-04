do_install:append() {
    sed -i -e 's/^#PermitRootLogin\(.*\)/PermitRootLogin no/g' ${D}${sysconfdir}/ssh/sshd_config
    if ${@bb.utils.contains('OMNECT_RELEASE_IMAGE', '1', 'true', 'false', d)}; then
        sed -i -e 's/^#PasswordAuthentication\(.*\)/PasswordAuthentication no/g' ${D}${sysconfdir}/ssh/sshd_config
    fi
}
