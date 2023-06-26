inherit aziot useradd


GROUPADD_PARAM:${PN} += " \
  -r omnect_device_service; \
  -r adu; \
  -r omnect_validate_update; \
"

# omnect-device-service needs groups rights for
# adu - editing adu consent file
# aziotcs,aziotid,aziotks - provistioning via iot-identity-service
USERADD_PARAM:${PN} += "--no-create-home -r -s /bin/false -G aziotcs,aziotid,aziotks,adu,omnect_validate_update -g omnect_device_service omnect_device_service;"
