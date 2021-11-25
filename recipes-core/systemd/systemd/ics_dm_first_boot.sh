#!/bin/bash
update-ca-certificates

[[ -f /mnt/factory/ics_dm_first_boot.sh ]] && source /mnt/factory/ics_dm_first_boot.sh
