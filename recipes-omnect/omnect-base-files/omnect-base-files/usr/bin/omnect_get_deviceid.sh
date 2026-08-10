#!/bin/bash

# toml exits non-zero with no output for an absent key, so an empty result is
# what selects the fallback
device_id=$(toml get /etc/aziot/config.toml provisioning.attestation.registration_id 2>/dev/null)
[ -n "${device_id}" ] \
    || device_id=$(toml get /etc/aziot/config.toml provisioning.device_id 2>/dev/null)

echo "${device_id}" | tr -d '"'
