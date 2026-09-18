#!/bin/sh
# Apply /etc/omnect/modem-config.json to the modem.
#
# Modem settings live in the modem's own memory, where neither flashing nor a
# factory reset reaches them, so the file is enforced on every boot and written
# only when it differs. Problems only warn: a failed unit would make the system
# "degraded" and break unrelated checks.

set -u

CAPS=/etc/omnect/device_caps.json
CONFIG=/etc/omnect/modem-config.json
CONFIG_VERSION=1
# a device that must have a modem is worth waiting for; where one is only optional
# the unit should not keep the system in "starting" for a minute
MODEM_WAIT_REQUIRED_SECS=60
MODEM_WAIT_OPTIONAL_SECS=20

cap() {
    jq -r --arg key "$1" '.[$key] // empty' "${CAPS}" 2>/dev/null
}

modem_present() {
    mmcli -L 2>/dev/null | grep -q '/Modem/'
}

# mmcli -K also prints a "...-bands.length" line, which must not end up in the list
modem_bands() {
    mmcli -m any -K 2>/dev/null |
        sed -n "s/^modem\.generic\.$1-bands\.value\[[0-9]*\][[:space:]]*:[[:space:]]*//p"
}

normalize() {
    tr '|' '\n' | tr -d '[:blank:]' | sed '/^$/d' | sort | tr '\n' ' '
}

case "$(cap 3g)" in
    yes)      modem_required=1; wait_secs=${MODEM_WAIT_REQUIRED_SECS} ;;
    optional) modem_required=0; wait_secs=${MODEM_WAIT_OPTIONAL_SECS} ;;
    *)        echo "no cellular capability, nothing to do"; exit 0 ;;
esac

[ -r "${CONFIG}" ] || { echo "no ${CONFIG}, nothing to do"; exit 0; }

version=$(jq -r '.version // empty' "${CONFIG}" 2>/dev/null)
if [ "${version}" != "${CONFIG_VERSION}" ]; then
    echo "WARNING: ${CONFIG} has version '${version}', expected ${CONFIG_VERSION}, ignoring it"
    exit 0
fi

bands=$(jq -r 'if (.bands | type) == "array" then (.bands | join("|"))
               elif .bands == "all" then "all"
               elif has("bands") then "invalid"
               else empty end' "${CONFIG}" 2>/dev/null)
if [ -z "${bands}" ]; then
    echo "no bands configured, nothing to do"
    exit 0
fi
if [ "${bands}" = "invalid" ]; then
    echo "WARNING: \"bands\" in ${CONFIG} is neither a list nor \"all\", ignoring it"
    exit 0
fi

waited=0
while ! modem_present && [ "${waited}" -lt "${wait_secs}" ]; do
    waited=$((waited + 1))
    sleep 1
done

if ! modem_present; then
    if [ "${modem_required}" -eq 1 ]; then
        echo "WARNING: no modem after ${wait_secs}s, configuration not applied"
    else
        echo "no modem present, nothing to do"
    fi
    exit 0
fi

supported=$(modem_bands supported | normalize)
if [ "${bands}" = "all" ]; then
    wanted="${supported}"
else
    wanted=$(echo "${bands}" | normalize)
    for band in ${wanted}; do
        case " ${supported} " in
            *" ${band} "*) ;;
            *)
                echo "WARNING: band '${band}' is not supported by this modem, configuration not applied"
                exit 0
                ;;
        esac
    done
fi

current=$(modem_bands current | normalize)
if [ "${current}" = "${wanted}" ]; then
    echo "bands already applied: ${wanted}"
    exit 0
fi

echo "applying bands: [${current}] -> [${wanted}]"
if ! mmcli -m any --set-current-bands="$(echo "${wanted}" | tr ' ' '|' | sed 's/|$//')"; then
    echo "WARNING: could not apply bands, retrying on next boot"
fi

exit 0
