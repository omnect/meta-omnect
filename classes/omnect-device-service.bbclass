inherit aziot useradd


GROUPADD_PARAM:${PN} += " \
  -r omnect_device_service; \
  -r disk; \
  -r adu; \
"

USERADD_PARAM:${PN} += "--no-create-home -r -s /bin/false -G aziotcs,aziotid,aziotks,disk,adu -g omnect_device_service omnect_device_service;"
