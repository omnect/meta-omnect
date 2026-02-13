inherit useradd

USERADD_PACKAGES = "${PN}"

GROUPADD_PARAM:${PN} = "-r wifi_commissioning"

USERADD_PARAM:${PN} = "--no-create-home -r -s /bin/false -g wifi_commissioning wifi_commissioning;"
