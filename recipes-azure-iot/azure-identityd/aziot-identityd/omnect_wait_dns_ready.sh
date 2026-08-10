#!/bin/bash

# aziot-identityd enrolls the device-id cert via EST and talks to DPS right at
# start, and exits with an error when the resolver cannot answer yet.
# network-online.target only tells us an interface is configured, so wait for
# the name the daemon actually needs.

AZIOT_CONFIG=/etc/aziot/config.toml
TIMEOUT_SECONDS=30
POLL_INTERVAL_SECONDS=1

# host of the first configured endpoint; est and dps are configured as urls,
# the iothub as a bare host
function endpoint_host()
{
    local key value

    for key in cert_issuance.est.urls.default \
               provisioning.global_endpoint \
               provisioning.iothub_hostname; do
        value=$(toml get "${AZIOT_CONFIG}" "${key}" 2>/dev/null | tr -d '"')
        [ -n "${value}" ] && [ "${value}" != "null" ] || continue
        value="${value#*://}"
        value="${value%%/*}"
        echo "${value%%:*}"
        return 0
    done

    return 1
}

host=$(endpoint_host) || exit 0

# a lookup without a usable resolver blocks for the resolver timeout, so the
# deadline is wall clock; counting attempts would multiply the wait by it
deadline=$(( SECONDS + TIMEOUT_SECONDS ))
while true; do
    getent ahosts "${host}" > /dev/null && exit 0
    [ "${SECONDS}" -lt "${deadline}" ] || break
    sleep ${POLL_INTERVAL_SECONDS}
done

echo "${host} does not resolve after ${TIMEOUT_SECONDS}s, starting anyway" >&2
exit 0
