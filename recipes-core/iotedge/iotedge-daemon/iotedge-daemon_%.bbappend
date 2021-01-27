inherit useradd

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM_${PN} += ";tpm"
GROUPMEMS_PARAM_${PN} = "-a iotedge -g tpm"
