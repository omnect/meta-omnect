# Since we don't know the DISTRO_FEATURES during layer.conf load time, we
# delay by using this special bbclass that simply includes the tpm
# configuration.

require conf/tpm-cfg.conf

# include machine specific config for tpm if necessary
include conf/machine/${MACHINE}.tpm.conf
