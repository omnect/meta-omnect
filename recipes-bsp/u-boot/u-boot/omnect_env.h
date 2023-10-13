#if !defined omnect_env_h
#define omnect_env_h

#include <configs/omnect_env_machine.h>

/* Attention: if vars are already part of CONFIG_EXTRA_ENV_SETTINGS
 * this doesnt work; these vars are shown correctly via userland fw_printenv,
 * but u-boot takes the default env value
 */
#define OMNECT_REQUIRED_WRITEABLE_ENV_FLAGS_EXTRA
#define OMNECT_REQUIRED_WRITEABLE_ENV_FLAGS \
    "omnect_os_bootpart:dw," \
    "data-mount-options:sw," \
    "factory-reset:dw," \
    "factory-reset-restore-list:sw," \
    "factory-reset-status:sw," \
    "flash-mode:dw," \
    "flash-mode-devpath:sw," \
    "omnect_validate_update:bw," \
    "omnect_validate_update_failed:bw," \
    "omnect_validate_update_part:dw," \
    "resized-data:sw," \
    OMNECT_REQUIRED_WRITEABLE_ENV_FLAGS_EXTRA

// activated by either u-boot_%.bbappend or u-boot-imx_%.bbappend
//#define OMNECT_RELEASE_IMAGE
#ifdef OMNECT_RELEASE_IMAGE
#define CONFIG_BOOTCOMMAND "run omnect_update_flow; reset"
#define OMNECT_ENV_SETTINGS \
    "bootdelay=-2\0" \
    "silent=1\0"
#else
#define CONFIG_BOOTCOMMAND "run omnect_update_flow"
#define OMNECT_ENV_SETTINGS
#endif //OMNECT_RELEASE

// set by either u-boot_%.bbappend or u-boot-imx_%.bbappend
#define OMNECT_ENV_BOOTLOADER_VERSION

// set by either u-boot_%.bbappend or u-boot-imx_%.bbappend
#define OMNECT_ENV_BOOTARGS

// u-boot part of omnect update workflow
#define OMNECT_ENV_UPDATE_WORKFLOW \
    "omnect_update_flow=" \
        "env exists omnect_os_bootpart || echo \"initializing omnect_os_bootpart=2\" && setenv omnect_os_bootpart 2 && saveenv;" \
        "if test -n ${omnect_validate_update}; then " \
            "echo \"Update validation failed - booting from partition ${omnect_os_bootpart}\";" \
            "setenv omnect_validate_update_part;" \
            "setenv omnect_validate_update;" \
            "setenv omnect_validate_update_failed 1;" \
            "saveenv;" \
            "run distro_bootcmd;" \
        "else " \
            "if test -n ${omnect_validate_update_part}; then " \
                "echo \"Update in progress - booting from partition ${omnect_validate_update_part}\";" \
                "setenv omnect_validate_update 1;" \
                "saveenv;" \
                "setenv omnect_os_bootpart ${omnect_validate_update_part};" \
                "run distro_bootcmd;" \
            "else "\
                "echo \"Normal boot - booting from partition ${omnect_os_bootpart}\";" \
                "run distro_bootcmd;" \
            "fi;" \
        "fi\0"

// for secureboot, or forcing e.g. silent env var not to be changeable in release image
#ifdef CONFIG_ENV_WRITEABLE_LIST
#define CONFIG_ENV_FLAGS_LIST_STATIC \
    OMNECT_REQUIRED_WRITEABLE_ENV_FLAGS \
    OMNECT_REQUIRED_WRITEABLE_ENV_FLAGS_MACHINE
#endif //CONFIG_ENV_WRITEABLE_LIST

// boot retry enabled, but not configured https://github.com/u-boot/u-boot/blob/master/doc/README.autoboot
#define CONFIG_BOOT_RETRY_TIME -1
#define CONFIG_RESET_TO_RETRY

#endif //omnect_env_h
