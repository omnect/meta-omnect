# LTE Support

While omnect OS is generally prepared for LTE support on respective
devices, for it to really work there can be some extra configuration
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

## Modem configuration

Settings like the band mask live in the modem's own memory. Neither flashing nor
a factory reset reaches them, so a device can carry a configuration from an
earlier owner that nothing in the image accounts for. `/etc/omnect/modem-config.json`
describes the wanted state instead, and `omnect-modem-config.service` enforces it
after every boot, writing to the modem only when it differs.

```
{
    "version": 1,
    "bands": ["eutran-1", "eutran-3", "eutran-7", "eutran-8", "eutran-20"]
}
```

What the file does not mention stays as it is, which is why the image ships a file
that configures nothing. `"bands"` is a list of band names as `mmcli` prints them,
or `"all"` for every band the modem supports — that is how a list inherited from
an earlier configuration is reset.

The value can come from a layer for a machine, or from a deployment that installs
its own file as `factory:/etc/omnect/modem-config.json`, which takes precedence
over the one in the image and is restored after a factory reset.

The package is part of the cellular package set, so it is only installed where
`MACHINE_FEATURES` contains `3g`. At runtime `/etc/omnect/device_caps.json`
decides: `yes` means a modem is expected and its absence is logged, `optional`
means the service applies the configuration if a modem shows up, anything else
means it does nothing.

A missing modem, a band the modem does not support, a file version the service
does not know or a rejected write only produce a warning and are retried on the
next boot. The service never fails: a failed unit would put the system into
`degraded` and break unrelated checks.
