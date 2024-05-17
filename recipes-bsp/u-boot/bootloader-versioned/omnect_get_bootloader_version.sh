#!/bin/bash

# following variables need to be replaced during build
VERSION_MAGIC="%%OMNECT_BOOTLOADER_EMBEDDED_VERSION_MAGIC%%"
PARAMSIZE="%%OMNECT_BOOTLOADER_EMBEDDED_VERSION_PARAMSIZE%%"
IMAGEOFFSET= "%%OMNECT_BOOTLOADER_EMBEDDED_VERSION_IMAGEOFFSET%%"
IMAGESIZE= "%%OMNECT_BOOTLOADER_EMBEDDED_VERSION_IMAGESIZE%%"
TYPE="%%OMNECT_BOOTLOADER_EMBEDDED_VERSION_TYPE%%"
BOOTLOADER_LOCATION="%%OMNECT_BOOTLOADER_EMBEDDED_VERSION_LOCATION%%"

# set some defaults if parameters above were set to empty string
: ${IMAGEOFFSET:=0}

set -e

#BOOTLOADER_BINARY_PATH=/boot/kernel8.img
#VERSION_NEGATIVE_OFFSET=1024

function get_bootloader_version() {
    local path="$1"
    local startoffset="$2"
    local size="$3"
    local negoffset="$4"
    local magicnums="$5"
    local off verstr

    off=$(stat -c "%s" "$path")
    off=$((off - negoffset))
    verstr=$(dd if="$path" bs=1 skip=$off count=32 | hexdump -c)
}

# version location seen from end-of-file
negoffset=${PARAMSIZE}
magicnums="${VERSION_MAGIC}"

case "${TYPE}" in
    file)
	path="${BOOTLOADER_LOCATION}"
	if [ ! -r "$path" ]; then
	    echo "FATAL: cannot find/read boot loader binary file \"$path\"." >&2
	    exit 1
	fi
	offset=0
	size=$(stat -c "%s" "$path")
	;;
    flash)
	path="/dev/omnect/rootblk"
	offset=${IMAGEOFFSET}
	size="${IMAGESIZE}"
	;;
    *)
	echo "FATAL: no or unrecognized bootloader type (\"${TYPE}\")"
	exit 1
esac

version=$(get_bootloader_version "${path}" ${offset}" "${size}" "${negoffset}" "${magicnums}")
