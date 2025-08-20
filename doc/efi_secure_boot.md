# UEFI secure boot
Currently we support secure boot only for x86 platforms.

## Certificate/Key Provisioning
- Enable Secure Boot in UEFI (Bios).
- Delete existing certificates in UEFI (Bios), e.g. "Erase all Secure Boot Settings". Note: If you "Reset Secure Boot to Factory" it may preset Microsoft certificates and thus prevent provisioning of omnect-os certificates.
- Boot to omnect-os and enforce certificate provisioning via:
    - `sudo mokutil --sbstate`<br>
      expected result:
      ```sh
      SecureBoot disabled
      Platform is in Setup Mode
      ```
    - `sudo bootloader_env.sh set omnect_force_sb_provision 1`
    - `sudo reboot`

    These steps result in a preselected grub menu entry "Certificate Provision". After executing this menu entry, grub will reboot.
- Boot to omnect-os and verify the secure boot state via:
    - `sudo mokutil --sbstate`<br>
      expected result:
      ```sh
      SecureBoot enabled
      ```
