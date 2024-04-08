#!/bin/sh
#
# Purpose of this script is to analyze service log files and rate their
# content, and hence the status of the respective service, as running normal,
# bearing warnings or failing at all.
#
# As it is completely service specific which entries lead wo what rating this
# kind of information needs to be passed along with the service log files to
# be processed.
#
# An additional requirement is to have multiple files with specifications of
# log entry 

. lib.sh

: ${CFGDIR:=/etc/omnect/health_check}
: ${CFGFILE:=omnect_service_log_analysis.json}
CFGFILEPATH="${CFGDIR}/${CFGFILE}"

: ${LOGDIR:=/run/omnect_health_log}
: ${ANALYSISDIR:=/run/omnect_health_log}

if [ ! -r "$CFGFILEPATH" ]; then
    warn "no configuration file (${CFGFILEPATH}) found, don't know what to do."
    exit 0
fi

# allow to select tests via command line
check_services="$*"

# remember overall rating
strrating=("GREEN" "YELLOW" "RED")
overall_rating=0
nentries=$(jq '.services | length' "$CFGFILEPATH")
[ "$check_services" ] || check_services=$(jq -r '[ .services[].service ] | join(" ")' "$CFGFILEPATH")
for ((n=0; n < nentries; n++)); do
    rating=0

    service=$(jq -r ".services[$n].service" "$CFGFILEPATH")
    [ "$(echo $check_services | grep -w "$service")" ] || continue
    
    servicelog="$LOGDIR/${service}.exit-log"
    hasratings=$(jq ".services[$n] | has(\".ratings\")" "$CFGFILEPATH")
    if [ ! -r "$servicelog" ]; then
	print_rating $rating "$service" "$ME"
	continue
    fi
    if $hasratings; then
	jquery=$(jq '.services[] | if (has("ratings")) then .ratings else empty end | map("(.infos[] | select(" + .condition + ")) += { \"rating\": \"" + .rating + "\"}") | join(" | ") ' ${CFGFILEPATH})
    else
	jquery=$(jq 'if (has("default-ratings")) then ."default-ratings" else empty end | map("(.infos[] | select(" + .condition + ")) += { \"rating\": \"" + .rating + "\"}") | join(" | ") | . + " | (.infos[] | select(has(\"rating\") | not)) += { \"rating\": \"red\" }"' ${CFGFILEPATH})
    fi
    eval jq $jquery "$servicelog" > "${servicelog}.rated"
    if [ $(jq '.infos | map(select(.rating == "red")) | length' "${servicelog}.rated") -gt 0 ]; then
	rating=2
    elif [ $rating -lt 1 -a $(jq '.infos | map(select(.rating == "yellow")) | length' "${servicelog}.rated") -gt 0 ]; then
	rating=1
    fi
    print_rating $rating "$service" "$ME"
    if [ $rating -gt $overall_rating ]; then
	overall_rating=$rating
    fi
done

# print_rating "" "omnect_service_log_analyze" "$ME"

exit $overall_rating
