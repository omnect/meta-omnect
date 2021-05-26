# Unfortunately as soon as we enable 'use_prov_client' in 'azure-iot-sdk-c'
# 'libiothub_client' will refer to symbols from 'libprov_auth_client'.
# We don't want that in apps which provision via 'iot-hub-identity-service'.
# For 'enrollment.bb' we need 'libprovisioning_service_client' and thus
# enable 'use_prov_client'. Therefore we have two recipes for
# 'azure-iot-sdk-c'.

require azure-iot-sdk-c_git.bb

EXTRA_OECMAKE += "-Duse_prov_client:BOOL=ON"

do_install_append() {
  cp -r ${S}/provisioning_service_client/inc/prov_service_client/* ${D}${includedir}/
  cp provisioning_service_client/libprovisioning_service_client.a ${D}${libdir}/
}
