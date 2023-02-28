inherit omnect-device-service

PACKAGECONFIG = "${@bb.utils.filter('DISTRO_FEATURES', 'ipv6', d)} libnftnl"

do_install:append() {
    chgrp omnect_device_service ${D}${sbindir}/xtables-nft-multi
    chmod 4750 ${D}${sbindir}/xtables-nft-multi

    sed -i \
        -e 's#^ExecStart=\(.*\)$#ExecStart=/usr/sbin/iptables-nft-restore -- /etc/iptables/iptables.rules#' \
        -e 's#^ExecReload=\(.*\)$#ExecReload=/usr/sbin/iptables-nft-restore -- /etc/iptables/iptables.rules#' \
        ${D}${systemd_system_unitdir}/iptables.service
    sed -i \
        -e 's#^ExecStart=\(.*\)$#ExecStart=/usr/sbin/ip6tables-nft-restore -- /etc/iptables/ip6tables.rules#' \
        -e 's#^ExecReload=\(.*\)$#ExecReload=/usr/sbin/ip6tables-nft-restore -- /etc/iptables/ip6tables.rules#' \
        ${D}${systemd_system_unitdir}/ip6tables.service
}
