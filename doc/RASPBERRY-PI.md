# Raspberry Pi 4 (raspberrypi4-64)

- **Product Page:** https://www.raspberrypi.org/
- **BSP (dynamic layer):** [meta-raspberrypi](https://github.com/agherzan/meta-raspberrypi.git)
- **UART:** */dev/ttyS0* is reserved in *OMNECT-gateway-devel_** images (bootloader + linux). In release images there are no restrictions.

## Omnect Feature Support:

| Feature | Availability |
| ------------------------------------ | :-------------: |
| **DPS Provisioning**                 | x509            |
| **OTA**                              | yes             |
| **Factory Reset**                    | yes             |
| **Wifi Commissioning via Bluetooth** | yes             |
| **LTE Support**                      | no              |

**Note:** More features can easily be enabled by adding appropriate expansion boards, e.g. TPM module or LTE modem.

## Device Tree Overlays

Refer to https://github.com/raspberrypi/firmware/blob/master/boot/overlays/README.
