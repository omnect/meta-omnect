#!/bin/bash

device_id=$(toml get /etc/aziot/config.toml provisioning.attestation.registration_id)
[[ "${device_id}" == "null" ]] && device_id=$(toml get /etc/aziot/config.toml provisioning.device_id)

echo ${device_id} | tr -d '"'
