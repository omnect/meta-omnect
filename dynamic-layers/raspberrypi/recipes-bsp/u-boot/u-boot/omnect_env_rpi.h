#if !defined omnect_env_machine_h
#define omnect_env_machine_h

/* for now make quirks_set writable for rpi4 0xC03111 test-boot.scr handling */
#define OMNECT_REQUIRED_WRITEABLE_ENV_FLAGS_MACHINE "," \
    "quirks_set:bw"

#endif //omnect_env_machine_h
