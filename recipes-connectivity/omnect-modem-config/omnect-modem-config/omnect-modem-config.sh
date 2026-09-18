#!/bin/sh
# Apply /etc/omnect/modem-config.json to the modem.
#
# The modem keeps settings like the band mask in its own non-volatile memory, where
# they survive reflashing and firmware updates. The file therefore describes the
# wanted state, which is enforced on every boot and written only when it differs.
#
# Nothing here fails the unit: a failed unit puts the system into "degraded" and
# breaks unrelated checks. Problems are logged and retried on the next boot.

set -u

CAPS=/etc/omnect/device_caps.json
CONFIG=/etc/omnect/modem-config.json
CONFIG_VERSION=1
MODEM_WAIT_SECS=60

cap() {
    jq -r --arg key "$1" '.[$key] // empty' "${CAPS}" 2>/dev/null
}

modem_present() {
    mmcli -L 2>/dev/null | grep -q '/Modem/'
}

# mmcli -K prints one "...<kind>-bands.value[N] : <band>" line per band, next to a
# "...<kind>-bands.length" line that must not end up in the list.
modem_bands() {
    mmcli -m any -K 2>/dev/null |
        sed -n "s/^modem\.generic\.$1-bands\.value\[[0-9]*\][[:space:]]*:[[:space:]]*//p"
}

normalize() {
    tr ',|' '\n\n' | tr -d '[:blank:]' | sed '/^$/d' | sort | tr '\n' ' '
}

[ "$(cap 3g)" = "yes" ] || { echo "no cellular capability, nothing to do"; exit 0; }
[ -r "${CONFIG}" ] || { echo "no ${CONFIG}, nothing to do"; exit 0; }

version=$(jq -r '.version // empty' "${CONFIG}" 2>/dev/null)
if [ "${version}" != "${CONFIG_VERSION}" ]; then
    echo "WARNING: ${CONFIG} has version '${version}', expected ${CONFIG_VERSION}, ignoring it"
    exit 0
fi

bands=$(jq -r '.bands // empty | if type == "array" then join("|") else . end' "${CONFIG}" 2>/dev/null)
if [ -z "${bands}" ]; then
    echo "no bands configured, nothing to do"
    exit 0
fi

waited=0
while ! modem_present && [ "${waited}" -lt "${MODEM_WAIT_SECS}" ]; do
    waited=$((waited + 1))
    sleep 1
done

if ! modem_present; then
    echo "WARNING: no modem after ${MODEM_WAIT_SECS}s, configuration not applied"
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
