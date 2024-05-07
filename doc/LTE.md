# LTE Support

While omnect OS is generally prepared for LTE support on respective
devices, for it to to really work there can be some extra configuration
necessary.

LTE support is handled by ...
- NetworkManager
- ModemManager
- mobile-broadband-provider-info database (from gnome)

A generic NetworkManager configuration for system connection like the
following allows to automatically connect to the mobile network in
most cases:

```
[connection]
id=cellular
type=gsm
autoconnect=true

[ipv4]
method=auto

[ipv6]
addr-gen-mode=stable-privacy
method=auto
```

For devices with LTE functionality such a generic configuration is
already part of the omnect OS image.
(see actual [configuration file](..//recipes-connectivity/networkmanager/files/cellular.generic))

However, it might not work with a chosen SIM card due to the fact that
the parameters used for identifying the correct connection settings -
mainly the APN, the Access Point Name - are not unique: the
combination of MCC (Mobile Country Code) and MNC (Mobile Network Code)
is unfortunately sometimes reused by resellers which have a different
APN setting.

In this case the above generic configuration needs to be augmented
with suitable settings, e.g.:

```
[gsm]
sim-operator-id=26202
apn=web.vodafone.de
```
