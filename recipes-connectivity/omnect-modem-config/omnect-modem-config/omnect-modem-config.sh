#!/bin/sh
# Apply /etc/omnect/modem-config.json to the modem. See doc/LTE.md for the file
# format and what the service does with it.
#
# Modem settings live in the modem's own memory, where neither flashing nor a
# factory reset reaches them, so the file is enforced on every boot.
#
# Problems only warn: a failed unit would make the system "degraded" and break
# unrelated checks.

# -f: band names from the config file are data, never glob patterns
set -uf

CAPS=/etc/omnect/device_caps.json
CONFIG=/etc/omnect/modem-config.json
CONFIG_VERSION=1
# a device that must have a modem is worth waiting for; where one is only optional
# the unit should not keep the system in "starting" for a minute
MODEM_WAIT_REQUIRED_SECS=60
MODEM_WAIT_OPTIONAL_SECS=20
MODEM_POLL_INTERVAL_SECS=2

cap() {
    jq -r --arg key "$1" '.[$key] // empty' "${CAPS}" 2>/dev/null
}

modem_present() {
    mmcli -L -J 2>/dev/null | jq -e '."modem-list" | length > 0' >/dev/null 2>&1
}

# reads the dump captured in ${modem_info}, so supported and current always
# describe the same view of the modem
modem_bands() {
    printf '%s' "${modem_info}" | jq -r --arg key "$1-bands" '.modem.generic[$key][]?'
}

# a band list is a set: order and repetition carry no meaning
normalize() {
    sed 's/[[:blank:]]//g; /^$/d' | sort -u | tr '\n' ' ' | sed 's/ *$//'
}

# mmcli models "every band" as the single band "any", but a modem may report the
# full supported list back instead
bands_match() {
    [ "$1" = "${wanted}" ] && return 0
    [ "${mode}" = "all" ] && [ "$1" = "${supported}" ] && return 0
    return 1
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

# first line is the mode, the rest are the band names, so a band called "all" or
# "invalid" cannot be mistaken for one
config=$(jq -r 'if (.bands | type) == "array" then
                    if (.bands | map(type == "string") | all)
                    then "list", (.bands[]) else "invalid" end
                elif .bands == "all" then "all"
                elif has("bands") then "invalid"
                else "unset" end' "${CONFIG}" 2>/dev/null)
mode=$(printf '%s\n' "${config}" | sed -n 1p)
bands=$(printf '%s\n' "${config}" | sed -n '2,$p' | normalize)

case "${mode}" in
    all) ;;
    list)
        if [ -z "${bands}" ]; then
            echo "WARNING: \"bands\" in ${CONFIG} is an empty list, ignoring it"
            exit 0
        fi
        ;;
    unset)
        echo "no bands configured, nothing to do"
        exit 0
        ;;
    invalid)
        echo "WARNING: \"bands\" in ${CONFIG} is neither a list of band names nor \"all\", ignoring it"
        exit 0
        ;;
    *)
        echo "WARNING: could not read ${CONFIG}, ignoring it"
        exit 0
        ;;
esac

found=0
deadline=$(( $(date +%s) + wait_secs ))
while :; do
    if modem_present; then
        found=1
        break
    fi
    [ "$(date +%s)" -lt "${deadline}" ] || break
    sleep "${MODEM_POLL_INTERVAL_SECS}"
done

if [ "${found}" -eq 0 ]; then
    if [ "${modem_required}" -eq 1 ]; then
        echo "WARNING: no modem after ${wait_secs}s, configuration not applied"
    else
        echo "no modem present, nothing to do"
    fi
    exit 0
fi

if ! modem_info=$(mmcli -m any -J 2>/dev/null); then
    echo "WARNING: could not read the modem state, configuration not applied"
    exit 0
fi

supported=$(modem_bands supported | normalize)
if [ -z "${supported}" ]; then
    echo "WARNING: the modem reports no supported bands, configuration not applied"
    exit 0
fi

if [ "${mode}" = "all" ]; then
    wanted=any
else
    wanted="${bands}"
    for band in ${wanted}; do
        if ! printf '%s\n' "${supported}" | tr ' ' '\n' | grep -Fxq "${band}"; then
            echo "WARNING: band '${band}' is not supported by this modem, configuration not applied"
            exit 0
        fi
    done
fi

current=$(modem_bands current | normalize)
if bands_match "${current}"; then
    echo "bands already applied: ${current}"
    exit 0
fi

echo "applying bands: [${current}] -> [${wanted}]"
if ! mmcli -m any --set-current-bands="$(printf '%s' "${wanted}" | tr ' ' '|')"; then
    echo "WARNING: could not apply bands, retrying on next boot"
    exit 0
fi

# a modem may accept the write and still store something else; without this the
# difference would be rewritten to non-volatile memory on every boot, unnoticed
if ! modem_info=$(mmcli -m any -J 2>/dev/null); then
    echo "WARNING: could not read the bands back, cannot tell whether they were stored"
    exit 0
fi
applied=$(modem_bands current | normalize)
if ! bands_match "${applied}"; then
    echo "WARNING: modem stored [${applied}] instead of [${wanted}], it will be written again on every boot"
fi

exit 0
