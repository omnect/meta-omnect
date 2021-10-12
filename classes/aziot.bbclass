inherit useradd

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM_${PN} = " \
  -r aziot; \
  -r aziotcs; \
  -r aziotid; \
  -r aziotks; \
  -r aziottpm; \
  -r tpm; \
"

USERADD_PARAM_${PN} = " \
  -r -g aziotcs -G aziot,aziotks -s /bin/false -d ${localstatedir}/lib/aziot/certd aziotcs; \
  -r -g aziotid -G aziot,aziotcs,aziotks,aziottpm -s /bin/false -d ${localstatedir}/lib/aziot/identityd aziotid; \
  -r -g aziotks -G aziot -s /bin/false -d ${localstatedir}/lib/aziot/keyd aziotks; \
  -r -g aziottpm -G aziot,tpm -s /bin/false -d ${localstatedir}/lib/aziot/tpmd aziottpm; \
"

do_install_prepend() {
    install -d -m 0775 -g aziot ${D}${sysconfdir}/aziot

    install -d -m 0750 -g aziotcs ${D}${sysconfdir}/aziot/certd
    install -d -m 0700 -o aziotcs -g aziotcs ${D}${sysconfdir}/aziot/certd/config.d

    install -d -m 0750 -g aziotid ${D}${sysconfdir}/aziot/identityd
    install -d -m 0700 -o aziotid -g aziotid ${D}${sysconfdir}/aziot/identityd/config.d

    install -d -m 0750 -g aziotks ${D}${sysconfdir}/aziot/keyd
    install -d -m 0700 -o aziotks -g aziotks ${D}${sysconfdir}/aziot/keyd/config.d
}
