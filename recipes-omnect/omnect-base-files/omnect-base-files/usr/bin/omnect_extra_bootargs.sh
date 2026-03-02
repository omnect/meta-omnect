#!/bin/bash

#todo check if boot is mounted
# check if we're root
[ -f /boot/extra_bootargs_omnect ] || touch /boot/extra_bootargs_omnect
[ -f /boot/extra_bootargs_custom ] || touch /boot/extra_bootargs_custom

current_bootargs=$(bootloader_env.sh get extra_bootargs)
new_bootargs="$(cat /boot/extra_bootargs_omnect) $(cat /boot/extra_bootargs_custom)"
new_bootargs="$(echo ${new_bootargs} | awk '{$1=$1};1')" # remove possibly trailing space


if [ "${current_bootargs}" != "${new_bootargs}" ] && [ -n "${new_bootargs}" ]; then
  bootloader_env.sh set extra_bootargs ${new_bootargs}
fi
