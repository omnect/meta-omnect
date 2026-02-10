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
| [**Secure Boot**](efi_secure_boot.md)| yes                     |
| **pstore** aka reboot reasons        | planned [^2]            |

[^1]: in [LTE documentation](LTE.md) you can find more details concerning configuration
[^2]: there exist BIOS versions for Arrakis Mk3 series devices containing an issue with heavy use of EFI variables which eventually causes a boot failure due to no more boot entries in the BIOS; while EFI variables form the base of the [**pstore** feature](Feature-pstore) implementation for devices using BIOS as initial boot loader (opposed to U-Boot) this feature cannot be enabled on such devices, yet.

**Note:** depending on the device watchdog support might not be given, because for example Arrakis Mk4 devices use a dedicated super IO chip which lacks integration into Linux kernel's watchdog infrastructure.
