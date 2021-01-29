inherit useradd

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM_${PN} += "; -r tpm"
GROUPMEMS_PARAM_${PN} = "-a iotedge -g tpm"
