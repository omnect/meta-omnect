# Arrakis Series

- **Product Page:** <https://welotec.com/de/collections/arrakis>
- **BSP (dynamic layer):** [meta-yocto-bsp](https://git.yoctoproject.org/poky/tree/meta-yocto-bsp)
- **Boot Media:**
  - 1st it is tried to boot *omnect-os* from USB media
  - 2nd if USB media is not present the internal nvme will be booted.
- **Flash internal nvme:**
  - boot *omnect-os* from USB
  - use [flash-mode 1](../README.md#flash-mode-1) in order to flash an image from USB to the internal hard drive
    - if your device has nvme, the device path is */dev/nvme0n1*
    - if your device has sata, the device path is */dev/sda*
  - remove USB media and power on device

## Omnect Feature Support

| Feature | Availability |
| ------------------------------------ | :---------------------: |
| **Device Provisioning via**          | x509 or TPM             |
| **OTA Update**                       | yes                     |
| **Factory Reset**                    | yes                     |
| **Wifi Commissioning via Bluetooth** | no                      |
| **LTE Support** [^1]                 | optional (experimental) |
| **pstore** aka reboot reasons        | planned                 |

[^1]: in [LTE documentation](LTE.md) you can find more details concerning configuration
