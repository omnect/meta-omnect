#!/bin/bash

function help() {
    echo "usage:"
    echo "bootloader_env.sh command key [value]"
    echo "    command: {get,list,set,unset}"
}

function cmd_get() {
    [[ ${#} -ne 1 ]] && help && exit 1
    local key="${1}"
    local value=$(fw_printenv -- "${key}")
    value="${value#"${key}"=}"
    [[ -z "${value}" ]] && echo && exit 2
    echo "${value}"
}

function cmd_list() {
    [[ ${#} -ne 0 ]] && help && exit 1
    fw_printenv
}

function cmd_set() {
    [[ ${#} -ne 2 ]] && help && exit 1
    local key="${1}"
    local value="${2}"

    # '--' ends option parsing, so key and value are always treated as data.
    # this blocks script mode and every other option, e.g. an attacker-chosen
    # config file, which a flag blocklist would miss (getopt accepts attached
    # values like -sFILE and abbreviations like --scr=FILE)
    fw_setenv -- "${key}" "${value}"
}

function cmd_unset() {
    [[ ${#} -ne 1 ]] && help && exit 1
    local key="${1}"
    fw_setenv -- "${key}"
}

[[ ${#} -lt 1 ]] && help && exit 1
declare -F "cmd_${1}" > /dev/null || { help; exit 1; }

"cmd_${1}" "${@:2}"
