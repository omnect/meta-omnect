#!/bin/bash
grubenv="/boot/EFI/BOOT/grubenv"
commands=("get","list","set","unset")
argsc=${#}

function help() {
    echo "usage:"
    echo "bootloader_env.sh command key [value]"
    echo "    command: {get,set,unset}"
}

function get() {
    [[ ${argsc} -lt 2 ]] && help && exit 1
    local key=${1}
    local value=$(grub-editenv ${grubenv} list | grep ^${key}= | awk -F'=' '{print $2}')
    [[ -z "${value}" ]] && echo && exit 2
    echo ${value}
}

function list(){
    [[ ${argsc} -ne 1 ]] && help && exit 1
    grub-editenv ${grubenv} list
}

function set () {
    [[ ${argsc} -lt 3 ]] && help && exit 1
    local key=${1}
    local value=${2}
    grub-editenv ${grubenv} set ${key}=${value}
}

function unset() {
    [[ ${argsc} -lt 2 ]] && help && exit 1
    local key=${1}
    grub-editenv ${grubenv} unset ${key}
}

[[ ${#} -lt 1 ]] && help && exit 1
[[ ! "${commands[@]}" =~ "${1}" ]] && help && exit 1

#exec
${1} ${@:2}
