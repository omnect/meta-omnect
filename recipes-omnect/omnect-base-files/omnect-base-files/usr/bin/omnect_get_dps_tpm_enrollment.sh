#!/bin/sh

# location of the endorsement key in the tpm device
ek_address=0x81010001

cd /tmp

tpm2_readpublic -Q -c ${ek_address} -o ek.pub 2> /dev/null

printf "Gathering the registration information...\n\nEndorsement Key:\n%s\n" $( base64 -w0 ek.pub)
rm ek.pub 2> /dev/null
