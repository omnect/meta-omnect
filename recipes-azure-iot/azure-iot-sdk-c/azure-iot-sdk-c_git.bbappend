# fix compilation of dependency azure-device-update
do_configure_prepend() {
   sed -i 's/${OPENSSL_LIBRARIES}/crypto/g' ${S}/c-utility/CMakeLists.txt
   sed -i 's/${CURL_LIBRARIES}/curl/g' ${S}/c-utility/CMakeLists.txt
}

# fix installation of provision_service_client
do_install_append() {
  cp -r ${S}/provisioning_service_client/inc/prov_service_client/* ${D}${includedir}/
  cp provisioning_service_client/libprovisioning_service_client.a ${D}${libdir}/
}
