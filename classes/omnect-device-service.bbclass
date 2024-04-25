inherit aziot useradd

GROUPADD_PARAM:${PN} += " \
  -r adu; \
  -r omnect_device_service; \
  -r -g 10000 omnect_device_socket; \
  -r ssh_tunnel_user; \
"

# omnect-device-service.socket user and group
USERADD_PARAM:${PN} += "--no-create-home -r -s /bin/false -u 10000 -g 10000 omnect_device_socket;"

# omnect-device-service needs groups rights for
# adu - editing adu consent file
# aziotcs,aziotid,aziotks - provisioning via iot-identity-service
USERADD_PARAM:${PN} += "--no-create-home -r -s /bin/false -G aziotcs,aziotid,aziotks,adu -g omnect_device_service omnect_device_service;"

# ssh_tunnel_user requires no permissions
USERADD_PARAM:${PN} += "--no-create-home -r -s /bin/false -G omnect_device_service -g ssh_tunnel_user ssh_tunnel_user;"
