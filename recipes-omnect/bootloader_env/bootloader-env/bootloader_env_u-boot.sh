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
    local value=$(fw_printenv -- "${key}")
    value=${value#"${key}"=}
    [[ -z "${value}" ]] && echo && exit 2
    printf '%s\n' "${value}"
}

function list(){
    [[ ${argsc} -ne 1 ]] && help && exit 1
    fw_printenv
}

function set () {
    [[ ${argsc} -ne 3 ]] && help && exit 1
    local key=${1}
    local value=${@:2}

    # '--' ends option parsing, so key and value are always treated as data.
    # this blocks script mode and every other option, e.g. an attacker-chosen
    # config file, which a flag blocklist would miss (getopt accepts attached
    # values like -sFILE and abbreviations like --scr=FILE)
    fw_setenv -- "${key}" "${value}"
}

function unset() {
    [[ ${argsc} -ne 2 ]] && help && exit 1
    local key=${1}
    fw_setenv -- "${key}"
}

[[ ${#} -lt 1 ]] && help && exit 1
[[ ! " ${commands[@]} " =~ " ${1} " ]] && help && exit 1

#exec
${1} ${@:2}
