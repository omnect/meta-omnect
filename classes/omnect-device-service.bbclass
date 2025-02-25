inherit aziot useradd

# we create an omnect_device_service_client user and group with static uid/gid 10000.
# they can be used by containers (or other programs) on all image variants and versions
# to get required socket permissions
GROUPADD_PARAM:${PN} += " \
  -r adu; \
  -r omnect_device_service; \
  -r -g 10000 omnect_device_service_client; \
  -r ssh_tunnel_user; \
"

# omnect-device-service.socket user and group
# aziotcs - allow reading certs under /var/lib/aziot/certd/certs/*
# aziotks - allow reading keys under /var/lib/aziot/keyd/keys/*
USERADD_PARAM:${PN} += "--no-create-home -r -s /bin/false -G aziotcs,aziotks -u 10000 -g 10000 omnect_device_service_client;"

# omnect-device-service needs groups rights for
# adu - editing adu consent file
# aziotcs,aziotid,aziotks - provisioning via iot-identity-service
# omnect_device_service_client - access directories owned by applications running under this group
USERADD_PARAM:${PN} += "--no-create-home -r -s /bin/false -G aziotcs,aziotid,aziotks,adu,omnect_device_service_client -g omnect_device_service omnect_device_service;"

# ssh_tunnel_user requires no permissions
USERADD_PARAM:${PN} += "--no-create-home -r -s /bin/false -G omnect_device_service -g ssh_tunnel_user ssh_tunnel_user;"
