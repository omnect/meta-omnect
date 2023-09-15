#!/bin/bash
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
    local value=$(fw_printenv ${key} | grep ^${key}= | awk -F'=' '{print $2}')
    [[ -z "${value}" ]] && echo && exit 2
    echo ${value}
}

function list(){
    [[ ${argsc} -ne 1 ]] && help && exit 1
    fw_printenv
}

function set () {
    [[ ${argsc} -ne 3 ]] && help && exit 1
    local key=${1}
    local value=${2}
    fw_setenv ${key} ${value}
}

function unset() {
    [[ ${argsc} -ne 2 ]] && help && exit 1
    local key=${1}
    fw_setenv ${key}
}

[[ ${#} -lt 1 ]] && help && exit 1
[[ ! " ${commands[@]} " =~ " ${1} " ]] && help && exit 1

#exec
${1} ${@:2}
