#if !defined omnect_env_h
#define omnect_env_h

#define OMNECT_ENV_SETTINGS \

#define OMNECT_ENV_UPDATE_WORKFLOW \
    "bootcmd=run omnect_update_flow\0" \
    "omnect_update_flow=\
        if test -n ${omnect_validate_update}; then \
            echo \"Update validation failed - booting from partition ${bootpart}\"; \
            setenv omnect_validate_update_part; \
            setenv omnect_validate_update; \
            saveenv; \
            run distro_bootcmd; \
        else \
            if test -n ${omnect_validate_update_part}; then \
                echo \"Update in progress - booting from partition ${omnect_validate_update_part}\"; \
                setenv omnect_validate_update 1; \
                saveenv; \
                setenv bootpart ${omnect_validate_update_part}; \
                run distro_bootcmd; \
            else \
                run distro_bootcmd; \
            fi; \
        fi\0" \

#endif
