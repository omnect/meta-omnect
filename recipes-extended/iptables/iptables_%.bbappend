inherit omnect-device-service

PACKAGECONFIG = "${@bb.utils.filter('DISTRO_FEATURES', 'ipv6', d)} libnftnl"

do_install:append() {
    chgrp omnect_device_service ${D}${sbindir}/xtables-nft-multi
    chmod 4750 ${D}${sbindir}/xtables-nft-multi
}
