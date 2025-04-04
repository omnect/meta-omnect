#!/bin/bash
grubenv="/boot/EFI/BOOT/grubenv"
commands=("get" "list" "set" "unset")
argsc=${#}

function help() {
    echo "usage:"
    echo "bootloader_env.sh command key [value]"
    echo "    command: {get,list,set,unset}"
}

function get() {
    [[ ${argsc} -ne 2 ]] && help && exit 1
    local key=${1}
    local value=$(grub-editenv ${grubenv} list | grep ^${key}=)
    value=${value#${key}=}
    [[ -z "${value}" ]] && echo && exit 2
    echo ${value}
}

function list(){
    [[ ${argsc} -ne 1 ]] && help && exit 1
    grub-editenv ${grubenv} list
}

function set () {
    [[ ${argsc} -ne 3 ]] && help && exit 1
    local key=${1}
    local value=${@:2}
    grub-editenv ${grubenv} set "${key}"="${value}"
    sync
}

function unset() {
    [[ ${argsc} -ne 2 ]] && help && exit 1
    local key=${1}
    grub-editenv ${grubenv} unset "${key}"
    sync
}

[[ ${#} -lt 1 ]] && help && exit 1
[[ ! " ${commands[@]} " =~ " ${1} " ]] && help && exit 1

#exec
${1} ${@:2}
