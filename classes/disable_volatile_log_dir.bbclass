# We want a nonvolatile /var/log when DISTRO_FEATURE "persistent-var-log" is
# set, but DISTRO_FEATURES can't be read at conf-parse time; so this class is
# inherited conditionally via USER_CLASSES instead.
# wrynose (5.1) dropped VOLATILE_LOG_DIR; /var/log is now non-volatile by
# dropping its perms table from FILESYSTEM_PERMS_TABLES.
FILESYSTEM_PERMS_TABLES:remove = "files/fs-perms-volatile-log.txt"
