# Arrakis-pico-MK3

- **Product Page:** https://www.welotec.com/de/industrie-pcs/
- **BSP (dynamic layer)):** [meta-welotec-bsp](https://github.com/omnect/meta-welotec-bsp)
- **Boot Media:**
  - configure BIOS settings to switch between USB and nvme as boot device. 
  - use [flash-mode 1](../README.md#flash-mode-1) in order to flash an image from USB to nvme
  - nvme device path is */dev/nvme0n1*
- **UART:** */dev/ttymxc2* is reserved in *OMNECT-gateway-devel_** images (bootloader + linux). In release images there are no restrictions.

## Omnect Feature Support:

| Feature | Availability |
| ------------------------------------ | :-------------: |
| **DPS Provisioning**                 | x509 and TPM    |
| **OTA**                              | yes             |
| **Factory Reset**                    | yes             |
| **Wifi Commissioning via Bluetooth** | no              |
| **LTE Support**                      | yes             |
