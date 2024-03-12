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

# get exit-log entries considered errors:
# jq 'del(.infos[] | select(.exitcode == "exited" or .exitcode == "killed")) | . += {"rating": "red"}' /run/omnect_health_log/omnect-device-service.exit-log

# get exit-log entries considered warnings only:
# jq 'del(.infos[] | select(.exitcode == "killed" | not)) | . += {"rating": "yellow"}' /run/omnect_health_log/omnect-device-service.exit-log

# rate all entries
# jq '(.infos[] | select(.exitcode == "killed")) += { "rating": "yellow"} | (.infos[] | select(.exitcode == "exited")) += { "rating": "ignored" } | (.infos[] | select(.exitcode != "killed" and .exitcode != "exited")) += {"rating": "red" }' /run/omnect_health_log/omnect-device-service.exit-log
# better rate everything not yet rated "red":
# <  /run/omnect_health_log/omnect-device-service.exit-log jq '(.infos[] | select(.exitcode == "killed")) += { "rating": "yellow"} | (.infos[] | select(.exitcode == "exited")) += { "rating": "ignored" } | (.infos[] | select(has("rating") | not)) += {"rating": "red" }'

# < omnect-device-service.analysis jq 'del(.infos[] | select(.rating != "yellow"))'
# < omnect-device-service.analysis jq 'del(.infos[] | select(.rating != "red"))'

# < omnect-device-service.analysis jq 'del(.infos[] | select(.rating != "red")) | del(.infos[].rating) | (. += { rating: "red"})'
# < omnect-device-service.analysis jq 'del(.infos[] | select(.rating != "yellow")) | del(.infos[].rating) | (. += { rating: "yellow"})'
# < omnect-device-service.analysis jq 'del(.infos[] | select(.rating != "ignored")) | del(.infos[].rating) | (. += { rating: "ignored"})' > omnect-device-service.analysis.ignored

# compute timestamp of system start:
# (set -vx; now=$(date +%s); ups=$(set -- $(cat /proc/uptime); echo $1); ups=${ups%%.*}; upsince=$((now - ups)); date -d "@$upsince")

if [ ! -r "$CFGFILEPATH" ]; then
    warn "no configuration file (${CFGFILEPATH}) found, don't know what to do."
    exit 0
fi

# remember overall rating
strrating=("GREEN" "YELLOW" "RED")
overall_rating=0
nentries=$(jq '.services | length' "$CFGFILEPATH")
for ((n=0; n < nentries; n++)); do
    rating=0
    eval service=$(jq ".services[$n].service" "$CFGFILEPATH")
    servicelog="$LOGDIR/${service}.exit-log"
    hasratings=$(jq ".services[$n] | has(\".ratings\")" "$CFGFILEPATH")
    if [ ! -r "$servicelog" ]; then
	msg "[${strrating[$rating]}]\t$service"
	continue
    fi
    if $hasratings; then
	jquery=$(jq '.services[] | if (has("ratings")) then .ratings else empty end | map("(.infos[] | select(" + .condition + ")) += { \"rating\": \"" + .rating + "\"}") | join(" | ") ' omnect_service_log_analysis.json)
    else
	jquery=$(jq 'if (has("default-ratings")) then ."default-ratings" else empty end | map("(.infos[] | select(" + .condition + ")) += { \"rating\": \"" + .rating + "\"}") | join(" | ") | . + " | (.infos[] | select(has(\"rating\") | not)) += { \"rating\": \"red\" }"' omnect_service_log_analysis.json)
    fi
    eval jq $jquery "$servicelog" > "${servicelog}.rated"
    if [ $(jq '.infos | map(select(.rating == "red")) | length' "${servicelog}.rated") -gt 0 ]; then
	rating=2
    elif [ $rating -lt 1 -a $(jq '.infos | map(select(.rating == "yellow")) | length' "${servicelog}.rated") -gt 0 ]; then
	rating=1
    fi
    msg "[${strrating[$rating]}]\t$service"
    if [ $rating -gt $overall_rating ]; then
	overall_rating=$rating
    fi
done

msg "Overall rating: ${strrating[$overall_rating]}"

exit $overall_rating

