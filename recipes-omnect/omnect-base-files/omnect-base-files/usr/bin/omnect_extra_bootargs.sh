#!/bin/bash -e
set -o pipefail

commands=("get_current" "get_new" "set")
argsc=${#}

mountpoint -q /boot/ || { echo "/boot is not mounted"; return 1; }
[[ $(id -u) -eq 0 ]] || { echo "${0} must be run as root"; return 1; }

[ -f /boot/extra_bootargs_omnect ] || touch /boot/extra_bootargs_omnect
[ -f /boot/extra_bootargs_custom ] || touch /boot/extra_bootargs_custom

current_bootargs=$(bootloader_env.sh get extra_bootargs || true)
new_bootargs="$(cat /boot/extra_bootargs_omnect) $(cat /boot/extra_bootargs_custom)"
new_bootargs="$(echo ${new_bootargs} | awk '{$1=$1};1')" # remove possibly trailing space

function help() {
    echo "usage:"
    echo "bootloader_env.sh command key [value]"
    echo "    command: {get_current,get_new,set}"
}

function get_current() {
  echo ${current_bootargs}
}

function get_new() {
  echo ${new_bootargs}
}

function set() {
  if [[ "${current_bootargs}" != "${new_bootargs}" ]]; then
    if [[ -n "${new_bootargs}" ]]; then
      bootloader_env.sh set extra_bootargs "${new_bootargs}"
    else
      bootloader_env.sh unset extra_bootargs
    fi
  fi
}


[[ ${#} -lt 1 ]] && help && exit 1
[[ ! " ${commands[@]} " =~ " ${1} " ]] && help && exit 1

#exec
${1}
