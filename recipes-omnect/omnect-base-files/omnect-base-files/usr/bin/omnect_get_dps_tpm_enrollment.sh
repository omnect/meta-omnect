#!/bin/sh
export TPM2TOOLS_TCTI="device:/dev/tpmrm0"

cd /tmp
tpm2_createek --ek-context ek.ctx --key-algorithm rsa --public ek.pub

printf "Gathering the registration information...\n\nEndorsement Key:\n%s\n" $( base64 -w0 ek.pub)
rm ek.ctx ek.pub 2> /dev/null
