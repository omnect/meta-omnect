#
# Gather all common helper functions in this file
#

ME="${0##*/}"

print() {
    echo -e "$@"
}

msg() {
    print "${ME}: ${@}"
}

warn() {
    echo -e "${ME}: WARNING: ${@}" >&2
}

error() {
    echo -e "${ME}: ERROR: ${@}" >&2
}

fatal() {
    echo -e "${ME}: FATAL ERROR: ${@}" >&2
}

strrating=("GREEN" "YELLOW" "RED")
overall_rating=0

print_rating() {
    local rating="${1:-${overall_rating}}"
    local info="$2"
    local file="$3"
    local ratingstr str
    local extrainfo="${file:+  (${file})}"

    printf -v ratingstr "%-9s" "[${strrating[${rating}]}]"
    printf -v str " %s %-25s  " "${ratingstr}" "$info"

    print "${str}${extrainfo}"
}

do_rate() {
    local rating="$1"
    local hint="$2"

    case "X$rating" in
	X0)
	    : # everything fine here
	;;
	X1)
	    [ $overall_rating -ge 1 ] || overall_rating=1
	    ;;
	X2)
	    [ $overall_rating -ge 2 ] || overall_rating=2
	    ;;
	*)
	    fatal "Unknown rating \"$rating\"${hint:-${ME}}"
	    ;;
    esac
}

do_rate_cmd() {
    local ret
    
    "$@"
    
    do_rate $? "$1"
}

get_overall_rating() {
    return $overall_rating
}
