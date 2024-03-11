#!/bin/sh
#
# Purpose of this script is to record service (re-)starts and terminations,
# regular as well as unintentional ones, in a generic way so that such
# occurrences can be examined by a health check routine.
#

. lib.sh

. lib.sh

SERVICE_EXITLOGDIRNAME=omnect_health_log
SERVICE_EXITLOGDIR=/var/run/${SERVICE_EXITLOGDIRNAME}

STOP_POSTFIX=".exit-log"
START_POSTFIX=".last-start"
START_1ST_POSTFIX=".1st-start"

function usage() {
    local do_exit="${1:--1}"
    
    cat <<-EOF
	Usage:

	   $ME start <service-name>
	   $ME stop  <service-name> <service-result> <exit-code> <exit-status>

	Generate a log entries in respective service log files ...
	 - for stop:
	    ${SERVICE_EXITLOGDIR}/<service-name>.$STOP_POSTFIX
	 - for start:
	    ${SERVICE_EXITLOGDIR}/<service-name>.$START_1ST_POSTFIX (first start only)
	    ${SERVICE_EXITLOGDIR}/<service-name>.$START_POSTFIX
EOF

    [ $do_exit -ge 0 ] && exit $do_exit
}

function output_logentry() {
    local outputfile="$1"
    local timestamp="$2"
    local service="$3"
    local result="$4"
    local exitcode="$5"
    local exitstatus="$6"
    
    if [ -r  "${outputfile}" ]; then
	jq '.infos += [{ timestamp: "'"$timestamp"'"'"${result:+, result: \"$result\"}""${exitcode:+, exitcode: \"$exitcode\"}""${exitstatus:+, exitstatus: \"$exitstatus\"}"' }]' < "$outputfile" > "${outputfile}.tmp"
	mv  "${outputfile}.tmp" "${outputfile}"
    else
	jq -n '{ service: "'"$service"'", infos: [ { timestamp: "'"$timestamp"'"'"${result:+, result: \"$result\"}""${exitcode:+, exitcode: \"$exitcode\"}""${exitstatus:+, exitstatus: \"$exitstatus\"}"' } ] }' > "$outputfile"
    fi
}

case "$1" in
    start)
	EXPECTED_PARAMS=2
    ;;
    stop)
	EXPECTED_PARAMS=5
    ;;
    *)
	error "unrecognized operation \"$1\" given"
    ;;
esac

[ $# -lt $EXPECTED_PARAMS ] && fatal "too few parameters ($# < $EXPECTED_PARAMS)" && usage 1
[ $# -gt $EXPECTED_PARAMS ] && warn "additional parameters ignored"

if [ ! -d "$SERVICE_EXITLOGDIR" ]; then
    mkdir "$SERVICE_EXITLOGDIR" \
	|| fatal "couldn't create directory \"$SERVICE_EXITLOGDIR\""
fi

SERVICE_EXITLOGFILE="$SERVICE_EXITLOGDIR/$2$STOP_POSTFIX"
SERVICE_STARTLOGFILE="$SERVICE_EXITLOGDIR/$2$START_POSTFIX"
SERVICE_STARTLOGFILE_1ST="$SERVICE_EXITLOGDIR/$2$START_1ST_POSTFIX"

timestamp=$(date +%Y-%m-%dT%H:%M:%SZ)

case "$1" in
    start)
	if [ ! -r "$SERVICE_STARTLOGFILE_1ST" ]; then
	    output_logentry "$SERVICE_STARTLOGFILE_1ST" "$timestamp" "$2"
	fi
	# output_logentry is always appending
	: > "SERVICE_STARTTLOGFILE"
	output_logentry "$SERVICE_STARTLOGFILE" "$timestamp" "$2"
    ;;
    stop)
	# FIXME: do we need to take care of log file rotation or removal?
	output_logentry "$SERVICE_EXITLOGFILE" "$timestamp" "$2" "$3" "$4" "$5"
    ;;
esac
