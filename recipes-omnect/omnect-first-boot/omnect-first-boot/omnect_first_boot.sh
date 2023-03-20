#!/bin/bash
update-ca-certificates

# create a first boot condition for aziot-identityd-precondition and omnect-device-service
install -m 0600 -g omnect_device_service -o omnect_device_service -D /dev/null /run/omnect-device-service/first_boot
