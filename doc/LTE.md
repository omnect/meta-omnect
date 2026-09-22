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
a factory reset reaches them, so the modem keeps whatever was written to it last:
its factory preset, or the bands set for wherever the device was used before. The
image alone does not say which. `/etc/omnect/modem-config.json` describes the
wanted state, and `omnect-modem-config.service` enforces it after every boot,
writing to the modem only when it differs.

```
{
    "version": 1,
    "bands": ["eutran-1", "eutran-3", "eutran-7", "eutran-8", "eutran-20"]
}
```

What the file does not mention stays as it is, and an image ships no such file, so
nothing is configured until one is installed. `"bands"` is a list of band names as `mmcli` prints them,
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

Nothing fails the unit: a failed unit would put the system into `degraded` and
break unrelated checks. A missing modem or a rejected write only warn, and the
next boot tries again. A band the modem does not support and a file version the
service does not know are fixed properties of the hardware or of the file, so
they repeat unchanged on every boot until the file is corrected; the warning in
the journal is the only sign.
