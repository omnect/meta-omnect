#!/bin/bash

# network-online.target does not mean the resolver can answer, and identityd
# exits with an error when it cannot resolve an endpoint at start.

AZIOT_CONFIG=/etc/aziot/config.toml
TIMEOUT_SECONDS=30
LOOKUP_TIMEOUT_SECONDS=5
POLL_INTERVAL_SECONDS=1

# est and dps are urls, the iothub a bare host
function url_host()
{
    local value="${1#*://}"

    value="${value%%/*}"
    value="${value##*@}"

    echo "${value%%:*}"
}

# which endpoint is needed first depends on the provisioning method, and they
# are not the same domain, so every configured one is probed
pending=()

for key in cert_issuance.est.urls.default \
           provisioning.global_endpoint \
           provisioning.iothub_hostname; do
    # toml prints nothing for an absent key
    value=$(toml get -r "${AZIOT_CONFIG}" "${key}")
    [[ -n "${value}" ]] || continue

    host=$(url_host "${value}")
    [[ -n "${host}" ]] || continue
    pending+=("${host}")
done

[[ ${#pending[@]} -gt 0 ]] || exit 0

# a failing lookup blocks for the resolver timeout, so cap the single lookup and
# the whole wait on wall clock. every host still pending gets a try per pass, so
# one that never resolves cannot eat the deadline of the others
deadline=$(( SECONDS + TIMEOUT_SECONDS ))

while [[ ${#pending[@]} -gt 0 && "${SECONDS}" -lt "${deadline}" ]]; do
    remaining=()

    for host in "${pending[@]}"; do
        timeout "${LOOKUP_TIMEOUT_SECONDS}" getent ahosts "${host}" > /dev/null \
            || remaining+=("${host}")
    done

    pending=("${remaining[@]}")
    [[ ${#pending[@]} -gt 0 ]] || break
    # a lookup that fails fast would spin this loop, so pace it
    sleep "${POLL_INTERVAL_SECONDS}"
done

[[ ${#pending[@]} -eq 0 ]] \
    || echo "${pending[*]} does not resolve within ${TIMEOUT_SECONDS}s, starting anyway" >&2

exit 0
