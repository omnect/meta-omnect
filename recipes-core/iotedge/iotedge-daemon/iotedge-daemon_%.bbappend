inherit useradd

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM_${PN} = "tpm"
USERADD_PARAM_${PN} = "--no-create-home -r -s /bin/false -g tpm iotedge"
#USERADD_PARAM_${PN}-iotedgeuser += "-G tpm2 iotedge"
#GROUPMEMS_PARAM${PN} = "-a iotedge -g tpm"