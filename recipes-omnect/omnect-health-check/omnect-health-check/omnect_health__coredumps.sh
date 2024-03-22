#!/bin/sh
#

. lib.sh

# at first find out time span we want to have core dumps for as we inly want
# to consider those that happened during this system run
now=$(date +%s)
up=$(set -- $(cat /proc/uptime); echo ${1%.*})
sinces=$((now - up))
since="$(date -d '@'"$sinces" +"%Y-%m-%d %H:%M:%S")"

cores=$(coredumpctl -q --json pretty --since "$since" | jq -r '. | map(.exe) | unique | join(",\n")')

if [ "${cores}" ]; then
    do_rate 2
else
    do_rate 0
fi

print_rating "" "coredumps" "$ME"

exit $overall_rating
