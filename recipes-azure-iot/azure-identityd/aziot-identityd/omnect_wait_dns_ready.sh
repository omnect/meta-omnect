#!/bin/bash

# network-online.target does not mean the resolver can answer, and identityd
# exits with an error when it cannot resolve its endpoint at start.

AZIOT_CONFIG=/etc/aziot/config.toml
TIMEOUT_SECONDS=30
POLL_INTERVAL_SECONDS=1

# est and dps are configured as urls, the iothub as a bare host
function endpoint_host()
{
    local key value

    for key in cert_issuance.est.urls.default \
               provisioning.global_endpoint \
               provisioning.iothub_hostname; do
        value=$(toml get "${AZIOT_CONFIG}" "${key}" 2>/dev/null | tr -d '"')
        [ -n "${value}" ] || continue
        value="${value#*://}"
        value="${value%%/*}"
        echo "${value%%:*}"
        return 0
    done

    return 1
}

host=$(endpoint_host) || exit 0

# a failing lookup blocks for the resolver timeout, so cap on wall clock and
# not on attempts
deadline=$(( SECONDS + TIMEOUT_SECONDS ))
while true; do
    getent ahosts "${host}" > /dev/null && exit 0
    [ "${SECONDS}" -lt "${deadline}" ] || break
    sleep ${POLL_INTERVAL_SECONDS}
done

echo "${host} does not resolve after ${TIMEOUT_SECONDS}s, starting anyway" >&2
exit 0
