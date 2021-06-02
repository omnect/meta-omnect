# We want to have a nonvolatile log dir, if DISTRO_FEATURE persistent-journal"
# is set, but we can not access 'DISTRO_FEATURES' directly at conf file load
# time.
# We delay using this special bbclass and the _append operator.
VOLATILE_LOG_DIR = "no"
