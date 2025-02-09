# override rolling SRCREV  "main" of iot-identity-service dependency
# with static rev
# aka 1.5.4:
iot_identity_service_rev = "2a8d851ae0d0a1a95903bbc3071f1c75887b2314"
SRCREV_aziot-cert-client-async = "${iot_identity_service_rev}"
SRCREV_aziot-cert-common-http = "${iot_identity_service_rev}"
SRCREV_aziot-certd-config = "${iot_identity_service_rev}"
SRCREV_aziot-identity-client-async = "${iot_identity_service_rev}"
SRCREV_aziot-identity-common = "${iot_identity_service_rev}"
SRCREV_aziot-identity-common-http = "${iot_identity_service_rev}"
SRCREV_aziot-identityd-config = "${iot_identity_service_rev}"
SRCREV_aziot-key-client = "${iot_identity_service_rev}"
SRCREV_aziot-key-client-async = "${iot_identity_service_rev}"
SRCREV_aziot-key-common = "${iot_identity_service_rev}"
SRCREV_aziot-key-common-http = "${iot_identity_service_rev}"
SRCREV_aziot-key-openssl-engine = "${iot_identity_service_rev}"
SRCREV_aziot-keyd-config = "${iot_identity_service_rev}"
SRCREV_aziot-keys-common = "${iot_identity_service_rev}"
SRCREV_aziot-tpmd-config = "${iot_identity_service_rev}"
SRCREV_aziotctl-common = "${iot_identity_service_rev}"
SRCREV_cert-renewal = "${iot_identity_service_rev}"
SRCREV_config-common = "${iot_identity_service_rev}"
SRCREV_http-common = "${iot_identity_service_rev}"
SRCREV_logger = "${iot_identity_service_rev}"
SRCREV_openssl-build = "${iot_identity_service_rev}"
SRCREV_openssl-sys2 = "${iot_identity_service_rev}"
SRCREV_openssl2 = "${iot_identity_service_rev}"
SRCREV_pkcs11 = "${iot_identity_service_rev}"
SRCREV_pkcs11-sys = "${iot_identity_service_rev}"
SRCREV_test-common = "${iot_identity_service_rev}"
