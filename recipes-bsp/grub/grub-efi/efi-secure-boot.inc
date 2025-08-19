get_efivar -f uint8 -s unprovisioned SetupMode

# load_env is done by grub-efi.cfg
if [ "${omnect_force_sb_provision}" = "1" -a "${unprovisioned}" = "1" ]; then

    # Create a boot entry for Automatic Certificate Provision.
    # This is especially useful for certain hardware, e.g,
    # Intel NUC5i3MYHE, doedn't support to display a customized
    # BIOS boot option used to launch LockDown.efi.
    if [ "x${provision_failed}" = "x" -o "x${provision_failed}" = "x0" ]; then
        set default="Certificate Provision"
    fi

    menuentry "Certificate Provision" --unrestricted {
        unset provision_failed
        save_env provision_failed
        unset omnect_force_sb_provision
        save_env omnect_force_sb_provision

        chainloader "${prefix}/LockDown.efi"
        boot
        set provision_failed="1"
        save_env provision_failed
        set omnect_force_sb_provision="1"
        save_env omnect_force_sb_provision
        sleep 60
        reboot
    }
fi
