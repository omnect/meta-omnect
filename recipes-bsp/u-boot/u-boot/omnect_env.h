#if !defined omnect_env_h
#define omnect_env_h

#include <configs/omnect_env_machine.h>

/* Attention: if vars are already part of CONFIG_EXTRA_ENV_SETTINGS
 * this doesnt work; these vars are shown correctly via userland fw_printenv,
 * but u-boot takes the default env value
 *
 * Every variable the OS writes at runtime belongs in this list. An unlisted
 * variable is not guaranteed to survive a u-boot saveenv, which
 * omnect_update_flow performs on the update paths.
 */
#define OMNECT_REQUIRED_WRITEABLE_ENV_FLAGS_EXTRA
#define OMNECT_REQUIRED_WRITEABLE_ENV_FLAGS \
    "data-mount-options:sw," \
    "factory-reset:sw," \
    "flash-mode:dw," \
    "flash-mode-devpath:sw," \
    "omnect_bootloader_updated:bw," \
    "omnect_extra_bootargs:sw," \
    "omnect_factory_reset_last_error:sw," \
    "omnect_first_boot_done:bw," \
    "omnect_fsck_boot:sw," \
    "omnect_fsck_cert:sw," \
    "omnect_fsck_data:sw," \
    "omnect_fsck_etc:sw," \
    "omnect_fsck_factory:sw," \
    "omnect_os_bootpart:dw," \
    "omnect_validate_extra_bootargs:sw," \
    "omnect_validate_update:bw," \
    "omnect_validate_update_failed:bw," \
    "omnect_validate_update_part:dw," \
    "resized-data:sw," \
    OMNECT_REQUIRED_WRITEABLE_ENV_FLAGS_EXTRA

// for secureboot, or forcing e.g. silent env var not to be changeable in release image
#ifdef CONFIG_ENV_WRITEABLE_LIST
#define CFG_ENV_FLAGS_LIST_STATIC \
    OMNECT_REQUIRED_WRITEABLE_ENV_FLAGS \
    OMNECT_REQUIRED_WRITEABLE_ENV_FLAGS_MACHINE
#endif //CONFIG_ENV_WRITEABLE_LIST
#endif //omnect_env_h
