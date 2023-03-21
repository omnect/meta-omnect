#if !defined omnect_env_machine_h
#define omnect_env_machine_h

// for now make quirks_set and extra-bootargs writable for rpi4 0xC03111 test-boot.scr handling
// ToDo: as soon we can get rid of boot scripts, we should create different u-boot envs for images vs. test-images
/* Attention: if vars are already part of CONFIG_EXTRA_ENV_SETTINGS
 * this doesnt work; these vars are shown correctly via userland fw_printenv,
 * but u-boot takes the default env value
 */
#define OMNECT_REQUIRED_WRITEABLE_ENV_FLAGS_MACHINE "," \
    "extra-bootargs:sw," \
    "quirks_set:bw"

#endif //omnect_env_machine_h
