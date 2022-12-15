#!/bin/sh

# location of the endorsement key in the tpm device
ek_address=0x81010001

cd /tmp

tpm2_readpublic -Q -c ${ek_address} -o ek.pub 2> /dev/null

# Registration Id will be calculated as checksum from the endorsement key
printf "Gathering the registration information...\n\nRegistration Id:\n%s\n\nEndorsement Key:\n%s\n" $(sha256sum -b ek.pub | cut -d' ' -f1 | sed -e 's/[^[:alnum:]]//g') $( base64 -w0 ek.pub)
rm ek.pub srk.ctx 2> /dev/null
