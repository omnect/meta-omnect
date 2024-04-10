#!/bin/bash

. lib.sh

CFGFILE=omnect_health_checks.json
CFGFILEDIR=/etc/omnect/health_check
CFGFILEPATH="${CFGFILEDIR}/${CFGFILE}"

function do_checks() {
    local cfgfile="$1"
    local selected_checks="$2"
    local nchecks check i idx name type extra_args

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
	[ "$(echo $selected_checks | grep -w "$name")" ] || continue

	extra_args=$(jq -r "if .[$idx].\"extra-args\" then .[$idx].\"extra-args\" else empty end" "$cfgfile")
	$check check $extra_args
    done
}

if [ "$old_stuff" ]; then
    for check in /etc/omnect/health_check/checks.d/*; do
	[ -x "$check" ] || continue
	
	do_rate_cmd "$check"
    done
else
    command="$1"
    check_command_arg "$command"
    shift

    [ -r "${CFGFILEPATH}" ] || { fatal "configuration file \"${CFGFILEPATH}\" not found"; exit 1; }

    # first argument must be either "check" or "get-infos"
    case "$command" in
	check)
	    do_checks "${CFGFILEPATH}" "$@"
	    retval=$?
	    ;;
	get-infos)
	    do_get_infos "$@"
	    ;;
    esac
fi

get_overall_rating
ret=$?

echo -e "\nOVERALL: $(print_rating)"

exit $ret
