#!/bin/sh
# Unit test for the cap() parser in omnect-wifi-commissioning-start.
# Runs the script's parser against the checked-in device_caps samples.
set -eu

HERE=$(dirname "$0")
SCRIPT="$HERE/omnect-wifi-commissioning-start"
CAPS_DIR="$HERE/../../../files/device_caps"

# Extract just the cap() function from the start script and exercise it.
run_cap() {
    CAPS="$1" sh -c '
        . '"$SCRIPT"'.capfn
        cap "'"$2"'"
    '
}

fail=0
check() { # file key expected
    got=$(run_cap "$CAPS_DIR/$1" "$2")
    if [ "$got" != "$3" ]; then
        echo "FAIL: $1 $2 => '$got' (expected '$3')"; fail=1
    else
        echo "ok: $1 $2 => '$got'"
    fi
}

check raspberrypi4-64.json wifi yes
check raspberrypi4-64.json bluetooth yes
check genericx86-64.json wifi optional
check genericx86-64.json bluetooth optional
check phygate-tauri-l-imx8mm-2.json wifi no
check phygate-tauri-l-imx8mm-2.json bluetooth no

exit $fail
