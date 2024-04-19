#!/bin/bash

. healthchecklib.sh

CFGFILE=omnect_health_checks.json
CFGFILEDIR=/etc/omnect/health_check
CFGFILEPATH="${CFGFILEDIR}/${CFGFILE}"

function verify_check_names() {
    local cfgfile="$1"
    shift
    local check known_checknames known_checktypes unknown_checks retval

    retval=0

    known_checknames=$(jq -r '[ .[].name ] | unique | join(" ")' "$cfgfile")
    known_checktypes=$(jq -r '[ .[].type ] | unique | join(" ")' "$cfgfile")

    for check; do
	[ "$(echo $known_checknames | grep -w "$check")" ] && continue
	[ "$(echo $known_checktypes | grep -w "$check")" ] && continue

	retval=1
	unknown_checks="${unknown_checks:+${unknown_checks} }${check}"
    done

    echo "$unknown_checks"
    [ "$unknown_checks" ] && retval=1
    
    return $retval
}

function do__cmd() {
    local cmd="$1"
    local output_when="$2" # 0 = never, 1 = failed only, 2 = all
    local cfgfile="$3"
    local selected_checks="$4"
    local nselected_checks nchecked nchecks check i idx name type extra_args
    local output retval

    nselected_checks=$(IFS=' ,'; set -- $selected_checks; echo $#)
    nchecked=0
    nchecks=$(jq 'length' "$cfgfile")
    [ $nchecks -gt 0 ] \
	|| { warn "no checks defined in config file \"$cfgfile\""; return 0; }
    
    i=0
    while [ $i -lt "$nchecks" ]; do
	idx=$i
	i=$((i + 1))

	type=$(jq -r "if .[$idx].\"type\" then .[$idx].\"type\" else empty end" "$cfgfile")
	[ "$type" ] \
	    || { warn "entry $i in \"$cfgfile\" is missing \"type\" attribute"; continue; }

	check="/usr/sbin/omnect_health__${type}.sh"
	[ -x "$check" ] \
	    || { warn "check \"$check\" for type \"$type\" (entry $i in \"$cfgfile\") cannot be called"; continue; }

	name=$(jq -r "if .[$idx].\"name\" then .[$idx].\"name\" else empty end" "$cfgfile")
	: ${name:=$type}
	[ -z "$selected_checks" -o "$(echo $selected_checks | grep -w "$name")" -o "$(echo $selected_checks | grep -w "$type")" ] || continue

	extra_args=$(jq -r "if .[$idx].\"extra-args\" then .[$idx].\"extra-args\" else empty end" "$cfgfile")
	output=$($check $cmd $extra_args)
	retval=$?
	do_rate $retval
	if [ $output_when = 2 -o $output_when = 1 -a $retval != 0 ]; then
	    echo "$output"
	fi
    done
}

function do_checks() {
    local cfgfile="$1"
    local selected_checks="$2"

    do__cmd check 2 "$cfgfile" "$2"
}

function do_get_infos() {
    local cfgfile="$1"
    local selected_checks="$2"

    do__cmd get-infos 1 "$cfgfile" "$2"
}

# let's set "check" as default command and allow parameter-less invocation
command="${1:-check}"
[ "$1" ] && shift
check_command_arg "$command"

[ -r "${CFGFILEPATH}" ] || { fatal "configuration file \"${CFGFILEPATH}\" not found"; exit 1; }

# first argument must be either "check" or "get-infos" other arguments are
# optional and contain names of checks
unknown=$(verify_check_names "${CFGFILEPATH}" "$@")
[ $? = 0 ] \
    || { error "unknown check name(s) [${unknown// /, }]"; exit 1; }
case "$command" in
    check)
	do_checks "${CFGFILEPATH}" "$*"
	retval=$?
	;;
    get-infos)
	do_get_infos "${CFGFILEPATH}" "$*"
	;;
esac

get_overall_rating
ret=$?

[ "$command" = check ] && echo -e "\nOVERALL: $(print_rating)"

exit $ret
