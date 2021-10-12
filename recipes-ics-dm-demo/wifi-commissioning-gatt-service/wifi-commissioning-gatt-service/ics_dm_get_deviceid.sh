#!/bin/bash

device_id=$(cat /etc/aziot/config.toml | grep ^registration_id | awk -F\" '{print $2}')
[[ -z "${device_id}" ]] && device_id=$(cat /etc/aziot/config.toml | grep ^device_id | awk -F\" '{print $2}')

echo ${device_id}
