#!/bin/sh
#

. lib.sh

checkit() {
    local retval
    
    # we use timedatectl to place variables into environment to be checked
    # afterward, but only use NTP variables as not all variables are properly
    # escaped for directly using it in that way

    eval $(timedatectl show | grep NTP)

    retval=$?

    if [ $retval -eq 0 ]; then
	if [ "$NTP" = yes ]; then
	    if [ "$NTPSynchronized" != yes ]; then
		retval=1
	    fi
	else
	    retval=2
	fi
    fi
    do_rate $retval
    return $retval
}

do_check() {
    local retval

    checkit
    retval=$?
    
    print_rating "" "timesync" "$ME"

    return $retval
}

do_get_infos() {
    local retval rating

    checkit
    retval=$?
    rating=$(get_overall_rating)
    
    print_info_header
    if [ $retval != 0 ]; then
	journalctl -b0 --no-pager -l -u systemd-timesyncd.service
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

exit $retval
