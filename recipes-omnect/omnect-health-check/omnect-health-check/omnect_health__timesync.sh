#!/bin/sh
#

. lib.sh

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
print_rating "" "timesync" "$ME"

exit $retval
