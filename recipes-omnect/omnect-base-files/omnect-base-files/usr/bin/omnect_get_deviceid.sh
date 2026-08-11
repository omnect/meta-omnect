#!/bin/bash

# toml prints nothing for an absent key
device_id=$(toml get -r /etc/aziot/config.toml provisioning.attestation.registration_id)
[[ -n "${device_id}" ]] \
    || device_id=$(toml get -r /etc/aziot/config.toml provisioning.device_id)

# sshd logs nothing of its own when the principals list comes back empty
[[ -n "${device_id}" ]] \
    || logger -t omnect_get_deviceid "no device id in /etc/aziot/config.toml"

echo "${device_id}"
