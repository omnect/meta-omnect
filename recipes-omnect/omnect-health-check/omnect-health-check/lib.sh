#
# Gather all common helper functions in this file
#

ME="${0##*/}"

msg() {
    echo -e "${ME}: ${@}"
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
