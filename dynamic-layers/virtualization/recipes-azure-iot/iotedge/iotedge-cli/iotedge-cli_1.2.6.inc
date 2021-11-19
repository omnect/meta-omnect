# ignore all instances of #[warn], #[deny], and #[forbid] lint directives
# otherwise edgelet-docker will fail caused by #[deny(rust_2018_idioms)]
#
# @todo check to remove that on iotedge updates
RUSTFLAGS += "--cap-lints allow"

# override rolling SRCREV  "relase/1.2" of iot-identity-service dependency
# with static rev
iot_identity_service_rev = "8fc413a9910588b2949eca8ad1ea28246c066f08"
SRCREV_aziot-cert-common-http = "${iot_identity_service_rev}"
SRCREV_aziot-certd-config = "${iot_identity_service_rev}"
SRCREV_aziot-identity-common = "${iot_identity_service_rev}"
SRCREV_aziot-identity-common-http = "${iot_identity_service_rev}"
SRCREV_aziot-identityd-config = "${iot_identity_service_rev}"
SRCREV_aziot-key-client = "${iot_identity_service_rev}"
SRCREV_aziot-key-common = "${iot_identity_service_rev}"
SRCREV_aziot-key-common-http = "${iot_identity_service_rev}"
SRCREV_aziot-key-openssl-engine = "${iot_identity_service_rev}"
SRCREV_aziot-keyd-config = "${iot_identity_service_rev}"
SRCREV_aziot-keys-common = "${iot_identity_service_rev}"
SRCREV_aziot-tpmd-config = "${iot_identity_service_rev}"
SRCREV_aziotctl-common = "${iot_identity_service_rev}"
SRCREV_config-common = "${iot_identity_service_rev}"
SRCREV_http-common = "${iot_identity_service_rev}"
SRCREV_openssl-build = "${iot_identity_service_rev}"
SRCREV_openssl-sys2 = "${iot_identity_service_rev}"
SRCREV_openssl2 = "${iot_identity_service_rev}"
SRCREV_pkcs11 = "${iot_identity_service_rev}"
SRCREV_pkcs11-sys = "${iot_identity_service_rev}"
