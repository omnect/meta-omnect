do_install:append() {
    sed -i -e 's/^#PermitRootLogin\(.*\)/PermitRootLogin no/g' ${D}${sysconfdir}/ssh/sshd_config
    if ${@bb.utils.contains('OMNECT_RELEASE_IMAGE', '1', 'true', 'false', d)}; then
        sed -i -e 's/^#PasswordAuthentication\(.*\)/PasswordAuthentication no/g' ${D}${sysconfdir}/ssh/sshd_config
    fi
    echo "AuthorizedPrincipalsCommand /usr/bin/omnect_get_deviceid.sh" >> ${D}${sysconfdir}/ssh/sshd_config
    echo "AuthorizedPrincipalsCommandUser sshd" >> ${D}${sysconfdir}/ssh/sshd_config
    echo "TrustedUserCAKeys /mnt/cert/ssh/root_ca" >> ${D}${sysconfdir}/ssh/sshd_config
}
