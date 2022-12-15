#!/bin/sh
if [ "$USER" != "root" ]; then
  SUDO="sudo "
fi

cd /tmp

$SUDO tpm2_readpublic -Q -c 0x81010001 -o ek.pub 2> /dev/null

printf "Gathering the registration information...\n\nRegistration Id:\n%s\n\nEndorsement Key:\n%s\n" $($SUDO sha256sum -b ek.pub | cut -d' ' -f1 | sed -e 's/[^[:alnum:]]//g') $($SUDO base64 -w0 ek.pub)
$SUDO rm ek.pub srk.ctx 2> /dev/null
