#!/bin/bash

# toml prints nothing for an absent key
device_id=$(toml get -r /etc/aziot/config.toml provisioning.attestation.registration_id)
[[ -n "${device_id}" ]] \
    || device_id=$(toml get -r /etc/aziot/config.toml provisioning.device_id)

echo "${device_id}"
