#!/bin/sh
#

. lib.sh

checkit() {
    local up now rating since sinces cores
    
    # at first find out time span we want to have core dumps for as we inly want
    # to consider those that happened during this system run
    rating=0
    now=$(date +%s)
    up=$(set -- $(cat /proc/uptime); echo ${1%.*})
    sinces=$((now - up))
    since="$(date -d '@'"$sinces" +"%Y-%m-%d %H:%M:%S")"
    
    cores=$(coredumpctl -q --json pretty --since "$since" | jq -r '. | map(.exe) | unique | join(",\n")')
    
    if [ "${cores}" ]; then
	rating=2
    fi
    do_rate $rating
    return $rating
}

do_check() {
    checkit
    print_rating "" "coredumps" "$ME"
    return $overall_rating
}

do_get_infos() {
    local retval
    
    checkit
    retval=$?

    print_info_header
    if [ $retval != 0 ]; then
	coredumpctl -r
    fi
    
    return $retval
}

command="$1"
check_command_arg "$command"
shift

# first argument must be either "check" or "get-infos"
case "$command" in
    check)
	do_check "$@"
	retval=$?
	;;
    get-infos)
	do_get_infos "$@"
	;;
esac

exit $overall_rating
