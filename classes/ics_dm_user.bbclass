#
#  Add ics-dm user with password set by ICS_DM_USER_PASSWORD environment variable
#

# generate password hash form (plain) password stored in environment
#   format /etc/shadow: $id$salt$hash,...
#       -> id=6 : SHA-512
ROOTFS_PREPROCESS_COMMAND:append = " ics_dm_setup_hash;"
ics_dm_setup_hash() {
    local hash_val
    if [ -z "${ICS_DM_USER_PASSWORD}" ]; then bbfatal "password not set for ics-dm user"; fi
    hash_val=$(${STAGING_BINDIR_NATIVE}/openssl passwd -6 ${ICS_DM_USER_PASSWORD})
    hash_val=$(echo -n $hash_val | tr -d '\n')  # drop trailing '\n'
    echo -n ${hash_val} >${WORKDIR}/ics_dm_pwd_hash
}

inherit extrausers
EXTRA_USERS_PARAMS = "\
    useradd -p '$(cat ${WORKDIR}/ics_dm_pwd_hash)' ics-dm; \
"
