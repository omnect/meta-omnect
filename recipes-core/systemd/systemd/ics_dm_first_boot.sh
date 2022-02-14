#!/bin/bash
update-ca-certificates

# If no 'enrollment' is available, the identity config is carried out during the first boot.
# The identity config depends on the device variant (edge / non edge).
if [ $(cat /etc/os-release | grep ^DISTRO_FEATURES | grep '[" ]enrollment[ "]' | wc -l) -eq 0 ]; then
  if [ $(cat /etc/os-release | grep ^DISTRO_FEATURES | grep '[" ]iotedge[ "]' | wc -l) -eq 1 ]; then
    iotedge config apply
  else
    aziotctl config apply
  fi
fi
