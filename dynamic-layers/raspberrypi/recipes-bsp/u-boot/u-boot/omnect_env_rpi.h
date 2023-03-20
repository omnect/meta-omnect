#if !defined omnect_env_machine_h
#define omnect_env_machine_h

// for now make quirks_set and extra-bootargs writable for rpi4 0xC03111 test-boot.scr handling
// ToDo: as soon we can get rid of boot scripts, we should create different u-boot envs for images vs. test-images
#define OMNECT_REQUIRED_WRITEABLE_ENV_FLAGS_MACHINE "," \
    "extra-bootargs:sw," \
    "quirks_set:bw"

#endif //omnect_env_machine_h
