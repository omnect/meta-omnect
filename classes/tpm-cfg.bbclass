# Since we don't know the DISTRO_FEATURES during layer.conf load time, we
# delay using this special bbclass that simply includes the tpm configuration.

require conf/tpm-cfg.conf
require conf/machine/${MACHINE}.tpm.conf
