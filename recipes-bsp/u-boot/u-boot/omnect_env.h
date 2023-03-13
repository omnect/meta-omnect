#if !defined omnect_env_h
#define omnect_env_h

// these VAR is changed on build by either u-boot_%.bbappend or u-boot-imx_%.bbappend
#define OMNECT_ENV_SETTINGS \

// u-boot part of omnect update workflow
#define OMNECT_ENV_UPDATE_WORKFLOW \
    "bootcmd=run omnect_update_flow\0" \
    "omnect_update_flow=" \
        "if test -n ${omnect_validate_update}; then " \
            "echo \"Update validation failed - booting from partition ${bootpart}\";" \
            "setenv omnect_validate_update_part;" \
            "setenv omnect_validate_update;" \
            "saveenv;" \
            "run distro_bootcmd;" \
        "else " \
            "if test -n ${omnect_validate_update_part}; then " \
                "echo \"Update in progress - booting from partition ${omnect_validate_update_part}\";" \
                "setenv omnect_validate_update 1;" \
                "saveenv;" \
                "setenv bootpart ${omnect_validate_update_part};" \
                "run distro_bootcmd;" \
            "else "\
                "run distro_bootcmd;" \
            "fi;" \
        "fi\0"

#define OMNECT_REQUIRED_WRITEABLE_ENV_FLAGS \
    "bootpart:dw," \
    "data-mount-options:sw," \
    "factory-reset:dw," \
    "factory-reset-restore-list:sw," \
    "factory-reset-status:sw," \
    "flash-mode:dw," \
    "flash-mode-devpath:sw," \
    "omnect_validate_update:bw," \
    "omnect_validate_update_part:dw"

/* for secureboot, or forcing e.g. silent env var not to be changeable in release image  */
#ifdef CONFIG_ENV_WRITEABLE_LIST
/* Set environment flag validation to a list of env vars that must be writable */
#define CONFIG_ENV_FLAGS_LIST_STATIC OMNECT_REQUIRED_WRITEABLE_ENV_FLAGS
#endif

#endif
