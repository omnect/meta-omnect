# Raspberry Pi 4 (raspberrypi4-64)

- **Product Page:** https://www.raspberrypi.org/
- **BSP (dynamic layer):** [meta-raspberrypi](https://github.com/agherzan/meta-raspberrypi.git)
- **UART:** */dev/ttyS0* is reserved for system console in OMNECT-gateway-devel images.

## Omnect Feature Support:

| Feature | Availability |
| ------------------------------------ | :-------------: 	  |
| **Device Provisioning via**          | x509            	  |
| **OTA Update**                       | yes             	  |
| **Factory Reset**                    | yes             	  |
| **Wifi Commissioning via Bluetooth** | yes             	  |
| **LTE Support**                      | no                   |
| **omnect_pstore** aka reboot reasons | yes (see note below) |

**Note:** More features can easily be enabled by adding appropriate expansion boards, e.g. TPM module or LTE modem.

**Note:** for **omnect_pstore**/reboot reason support a Raspberry Pi
4B (1.4) device needs to have at least EEPROM version
pieeprom-2024-10-21.bin or otherwise a watchdog reset will kill RAM
contents.
There is a docker image available which allows to check current EEPROM
version as well as upgrading to this very version:

[root@dut2-rpi4-x509-gateway-devel ~]# docker run --rm -ti --privileged -v /boot:/boot docker.io/omnect/rpi-eeprom:20250313-6aacd80-2024.11.08-2712

To check current EEPROM version simply launch `rpi-eeprom-update` in
container:

```bash
root@67542ffde28e:/# rpi-eeprom-update
BOOTLOADER: up to date
   CURRENT: Mon Apr 15 13:12:14 UTC 2024 (1713186734)
    LATEST: Mon Apr 15 13:12:14 UTC 2024 (1713186734)
   RELEASE: default (/lib/firmware/raspberrypi/bootloader/default)
            Use raspi-config to change the release.

  VL805_FW: Using bootloader EEPROM
     VL805: up to date
   CURRENT: 000138c0
    LATEST: 000138c0
```

For updating to the above mentioned version use this command:

```
root@67542ffde28e:/# rpi-eeprom-update -d -f /lib/firmware/raspberrypi/bootloader/latest/pieeprom-2024-10-21.bin
*** CREATED UPDATE /lib/firmware/raspberrypi/bootloader/latest/pieeprom-2024-10-21.bin  ***

   CURRENT: Mon Apr 15 13:12:14 UTC 2024 (1713186734)
    UPDATE: Mon Oct 21 14:24:54 UTC 2024 (1729520694)
    BOOTFS: /boot
'/tmp/tmp.PN6q8HHniz' -> '/boot/pieeprom.upd'
Copying recovery.bin to /boot for EEPROM update

EEPROM updates pending. Please reboot to apply the update.
To cancel a pending update run "sudo rpi-eeprom-update -r".
root@67542ffde28e:/# exit
[root@dut2-rpi4-x509-gateway-devel ~]# reboot
```

## Device Tree Overlays

Refer to https://github.com/raspberrypi/firmware/blob/master/boot/overlays/README.
