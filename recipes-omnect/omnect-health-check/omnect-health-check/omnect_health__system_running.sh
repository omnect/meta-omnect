#!/bin/sh
#

. healthchecklib.sh

function checkit() {
    do_rate_cmd systemctl -q is-system-running
}

function do_check() {
    local ret
    checkit
    ret=$?
    print_rating $ret system-running "$ME"
    return $ret
}

function do_get_infos() {
    local ret
    checkit
    ret=$?
    # TODO/FIXME: how to find and show reasons for this state?
    print_info_header "${ME}" "$ret"
    [ $ret = 0 ] || { systemctl is-system-running; systemctl --failed; }
    return $ret
}

command="${1:-check}"
[ "$1" ] && shift
check_command_arg "$command"

# first argument must be either "check" or "get-infos"
case "$command" in
    check)
	do_check "$@"
	retval=$?
	;;
    get-infos)
	do_get_infos "$@"
	retval=$?
	;;
esac

exit $retval
