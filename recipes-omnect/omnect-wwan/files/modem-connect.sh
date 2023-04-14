#!/bin/bash

# NOTE:
#   This script currently only uses fixed arguments for WWAN start up with
#   respect to modem mode IP and APN settings.
#   For a more generic approach there probably would be some configuration
#   files involved, maybe in /etc/defaults or /etc/omnect, which define such
#   parameters in shell variables and get somehow added to the root file
#   system (as part of a dedicated image or injected in exisiting images as
#   seen fit.)

cid=""
pdhandle=""

function do_connect_qmicli() {
    local out=
    local qmiclistate=

    out=$(qmicli --device=/dev/cdc-wdm0 --device-open-proxy --wds-start-network="ip-type=4,apn=internet.telekom" --client-no-release-cid)
    qmiclistate=$?
    echo "$out" | \
	while read l; do
	    first=$(set -- $l; echo "$1")
	    if [ "$first" == 'CID:' ]; then
		# line like "            CID: '7'"
		cid=$(IFS="${IFS}:'" set -- $l; echo $2)
		continue
	    fi
	    if [ "$first" == 'Packet' ]; then
		# line like "        Packet data handle: '2247935200'"
		pdhandle=$(IFS="${IFS}:'" set -- $l; echo $4)
		continue
	    fi
	done
    if [ $qmiclistate != 0 ]; then
	[ "$cid" ] && qmicli --wds-noop --client-cid "$cid"
	return 1
    fi
    return 0
}

function do_disconnect_qmicli() {
    qmicli -d /dev/cdc-wdm0 --stop-network=$pdhandle --client-cid="$cid"
}

function do_connect_mmcli() {
    mmcli -m 0 --simple-connect="apn=internet.telekom,ip-type=ipv4"
}

function do_disconnect_mmcli() {
    mmcli -m 0 --simple-disconnect
}

function do_connect() {
    local rval
    
    # ensure that LTE interface is down before connection gets started so
    # that systemd-networkd doesn't try to achieve an IP address via DHCP
    # before modem is ready
    ip link set down wwan0

    while : ; do
	sleep 1

	if [ "$use_qmicli" ]; then
	    do_connect_qmicli
	    rval=$?
	else
	    do_connect_mmcli
	    rval=$?
	fi
	if [ $rval = 0 ]; then
	    # modem connection is now considered up, work is done
	    break
	fi

	# let's retry after a short break
	sleep 10
	continue
    done

    # give link a little time to get fully established before systemd-
    # networkd starts sending DHCP discovery packets triggered by active
    # interface
    sleep 2
    ip link set up wwan0

    # echo "$cid $pdhandle"
}

function do_disconnect() {
    ip link set down wwan0    
    if [ "$use_qmicli" ]; then
	do_disconnect_qmicli
    else
	do_disconnect_mmcli
    fi
}

while :; do
    # connect ...
    do_connect
    # ... and check whether it's still up
    while :; do
	sleep 5
	#pktstate=$(qmicli -d /dev/cdc-wdm0 -p --wds-get-packet-service-status)
	# at least in some cases pings failed without prio nslookup, absolute
	# no idea why, thus add an nslookup as precaution ...
	out=$((nslookup 8.8.8.8 && ping -c 30 -I wwan0 8.8.8.8) 2>&1) > /dev/null || break
    done

    # when down/inoperable disconnect ...
    do_disconnect
    
    # ... and give a little time before reconnecting
    sleep 30
done
