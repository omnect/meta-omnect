#!/bin/sh

. lib.sh

for check in /etc/omnect/health_check/checks.d/*; do
    [ -x "$check" ] || continue

    do_rate_cmd "$check"
done

get_overall_rating
ret=$?

echo -e "\nOVERALL: $(print_rating)"

exit $ret
