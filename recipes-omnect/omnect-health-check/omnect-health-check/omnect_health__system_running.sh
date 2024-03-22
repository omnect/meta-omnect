#!/bin/sh
#

. lib.sh

do_rate_cmd systemctl -q is-system-running

print_rating "" system-running "$ME"

exit $overall_rating
