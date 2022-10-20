SRC_URI += " \
    file://ossl300_fix_incompatible_pointer_types.patch;patchdir=${WORKDIR}/aziot-cert-client-async \
    file://ossl300_openssl-errors.patch;patchdir=${WORKDIR}/aziot-cert-client-async \
"

# we patch aziot-cert-client-async to use openssl-errors 0.2 so we have to provide
# it and its dependencies
SRC_URI += " \
    crate://crates.io/cfg-if/0.1.10 \
    crate://crates.io/openssl-errors/0.2.0 \
"

# override rolling SRCREV  "relase/1.4" of iot-identity-service dependency
# with static rev
# aka 1.4.0:
iot_identity_service_rev = "c281b76772f16d7389fd6b25872c2119e539eab8"
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
