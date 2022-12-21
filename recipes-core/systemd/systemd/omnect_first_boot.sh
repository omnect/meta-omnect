#!/bin/bash
update-ca-certificates

# The identity config depends on the device variant (edge / non edge).
if [ $(cat /etc/os-release | grep ^DISTRO_FEATURES | grep '[" ]iotedge[ "]' | wc -l) -eq 1 ]; then
  iotedge config apply
else
  aziotctl config apply
fi
