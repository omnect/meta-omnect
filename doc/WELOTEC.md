# Arrakis-pico-MK3

- **Product Page:** https://www.welotec.com/de/industrie-pcs/
- **BSP (dynamic layer):** ToDo
- **Boot Media:**
  - 1st it is tried to boot *omnect-os* from USB media 
  - 2nd if USB media is not present the internal nvme will be booted.
- **Flash internal nvme:**
  - boot *omnect-os* from USB
  - use [flash-mode 1](../README.md#flash-mode-1) in order to flash an image from USB to nvme. The nvme device path is */dev/nvme0n1*
  - remove USB media and power on device 

## Omnect Feature Support:

| Feature | Availability |
| ------------------------------------ | :-------------: |
| **Device Provisioning via**          | x509 or TPM     |
| **OTA Update**                       | yes             |
| **Factory Reset**                    | yes             |
| **Wifi Commissioning via Bluetooth** | no              |
| **LTE Support**                      | experimental    |
