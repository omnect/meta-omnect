# UEFI secure boot
Currently we support secure boot only for x86 platforms.

## Certificate/Key Provisioning
- Enable Secure Boot in UEFI (Bios).
- Delete existing certificates in UEFI (Bios), e.g. "Erase all Secure Boot Settings". Note: If you "Reset Secure Boot to Factory" it may preset Microsoft certificates and thus prevent provisioning of omnect-os certificates.
- Boot to omnect-os and enforce certificate provisioning via:
    - `sudo mokutil --sb-state`<br>
      expected result:
      ```sh
      SecureBoot disabled
      Platform is in Setup Mode
      ```
    - `sudo bootloader_env.sh set omnect_force_sb_provision 1`
    - `sudo reboot`

    These steps result in a preselected grub menu entry "Certificate Provision". After executing this menu entry, grub will reboot.
- Boot to omnect-os and verify the secure boot state via:
    - `sudo mokutil --sb-state`<br>
      expected result:
      ```sh
      SecureBoot enabled
      ```

## Build
To build an `omnect-os` Image for `genericx86-64` with secure boot (mandatory), you have to generate keys, e.g. via https://github.com/Wind-River/meta-secure-core/blob/master/meta-signing-key/scripts/create-user-key-store.sh and provide build variables:
```sh
SIGNING_MODEL="user"
RPM=0
UEFI_SB_KEYS_DIR=<path to uefi_sb_keys>
MOK_SB_KEYS_DIR=<path to mok_sb_keys>
MODSIGN_KEYS_DIR=<path to modsign_keys>
SYSTEM_TRUSTED_KEYS_DIR=<path to system_trusted_keys>
SECONDARY_TRUSTED_KEYS_DIR=<path to secondary_trusted_keys>
```
