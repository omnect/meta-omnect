#!/bin/sh
# Start and configure wifi commissioning from /etc/omnect/device_caps.json.
# Runs once at boot (oneshot). No hot-plug: wlan0 is assumed present at boot.
set -eu

CAPS=/etc/omnect/device_caps.json
WCS_ENV=/etc/omnect/wifi-commissioning-service.env
ENV_FILE=/run/omnect-wifi-commissioning.env
IFACE=wlan0

# cap KEY -> value of "KEY" from the flat device_caps JSON in $CAPS ('' if absent).
cap() {
    jq -r --arg k "$1" '.[$k] // empty' "$CAPS"
}

wifi=$(cap wifi)
if [ "$wifi" != "yes" ]; then
    echo "wifi=${wifi:-<unset>}: not starting wifi commissioning"
    exit 0
fi

# Operator override: WCS_DISABLE_BLE in the wcs env file forces the BLE transport
# off at runtime, even when device_caps enables bluetooth. Lets one image ship BLE
# support but keep it off per device, without a rebuild. Parsed, not sourced, so a
# malformed env file cannot break boot.
ble_disabled=no
if [ -r "$WCS_ENV" ]; then
    val=$(sed -n 's/^[[:space:]]*WCS_DISABLE_BLE[[:space:]]*=[[:space:]]*//p' "$WCS_ENV" | tail -n1)
    val=${val%\"}; val=${val#\"}
    case "$val" in 1|true|yes|on) ble_disabled=yes ;; esac
fi

if [ "$(cap bluetooth)" = "yes" ] && [ "$ble_disabled" = "no" ]; then
    printf 'WCS_BLE_ARGS=--enable-ble\n' > "$ENV_FILE"
    echo "starting wifi commissioning on ${IFACE} with BLE"
else
    printf 'WCS_BLE_ARGS=\n' > "$ENV_FILE"
    echo "starting wifi commissioning on ${IFACE} without BLE"
fi

# --no-block: we are inside the boot transaction; do not wait on the started jobs.
# wpa_supplicant@%i pulls wifi-commissioning-service@%i via its Wants=.
systemctl start --no-block "wpa_supplicant@${IFACE}.service"
