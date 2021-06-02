#!/bin/bash
set -o errexit
set -o pipefail

boot_part=$(readlink -f /dev/disk/by-label/boot)
data_part=$(readlink -f /dev/disk/by-label/data)

[[ $(cat /proc/mounts | grep ${boot_part} | wc -l) -eq 0 ]] && echo "error: \"${boot_part}\" not mounted." && exit 1
[[ -e /boot/data-expanded ]] && echo "info: \"/boot/data-expanded\" exists. \"${data_part}\" already expanded." && exit 0
[[ $(cat /proc/mounts | grep ${data_part} | wc -l) -ne 0 ]] && echo "error: \"${data_part}\" is mounted." && exit 1

root_disk=${data_part%p*}
data_part_nr=${data_part##*p}

[[ $(parted ${root_disk} print all | grep extended | wc -l) -ne 1 ]] && echo "error: couldn't determine extended partion" && exit 1
extended_part_nr=$(parted ${root_disk} print all | grep extended | awk '{print $1}')

parted ${root_disk} resizepart ${extended_part_nr} 100%
parted ${root_disk} resizepart ${data_part_nr} 100%
e2fsck -y ${data_part}
resize2fs -f ${data_part}
sync
touch /boot/data-expanded
