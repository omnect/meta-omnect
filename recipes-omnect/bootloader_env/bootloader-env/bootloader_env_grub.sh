#!/bin/bash -e
set -o pipefail
grubenv="/boot/EFI/BOOT/grubenv"

function help() {
    echo "usage:"
    echo "bootloader_env.sh command key [value]"
    echo "    command: {get,list,set,unset}"
}

function cmd_get() {
    [[ ${#} -ne 1 ]] && help && exit 1
    local key="${1}"
    local value=$(grub-editenv "${grubenv}" list | grep "^${key}=")
    value="${value#"${key}"=}"
    [[ -z "${value}" ]] && echo && exit 2
    echo "${value}"
}

function cmd_list() {
    [[ ${#} -ne 0 ]] && help && exit 1
    grub-editenv "${grubenv}" list
}

function cmd_set() {
    [[ ${#} -ne 2 ]] && help && exit 1
    local key="${1}"
    local value="${2}"
    grub-editenv "${grubenv}" set "${key}"="${value}"
    sync
}

function cmd_unset() {
    [[ ${#} -ne 1 ]] && help && exit 1
    local key="${1}"
    grub-editenv "${grubenv}" unset "${key}"
    sync
}

[[ ${#} -lt 1 ]] && help && exit 1
declare -F "cmd_${1}" > /dev/null || { help; exit 1; }

"cmd_${1}" "${@:2}"
