#
#  Add factory_reset group
#
inherit useradd
USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM_${PN} = "-r factory_reset"
