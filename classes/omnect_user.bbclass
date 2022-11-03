#
#  Add omnect user with password set by OMNECT_USER_PASSWORD environment variable
#

# generate password hash form (plain) password stored in environment
#   format /etc/shadow: $id$salt$hash,...
#       -> id=6 : SHA-512
ROOTFS_PREPROCESS_COMMAND:append = " omnect_setup_hash;"
omnect_setup_hash() {
    local hash_val
    if [ -z "${OMNECT_USER_PASSWORD}" ]; then bbfatal "password not set for omnect user"; fi
    hash_val=$(${STAGING_BINDIR_NATIVE}/openssl passwd -6 ${OMNECT_USER_PASSWORD})
    hash_val=$(echo -n $hash_val | tr -d '\n')  # drop trailing '\n'
    echo -n ${hash_val} >${WORKDIR}/omnect_pwd_hash
}

inherit extrausers
EXTRA_USERS_PARAMS = "\
    groupadd -g 15581 omnect; \
    useradd -p '$(cat ${WORKDIR}/omnect_pwd_hash)' -u 15581 -g omnect omnect; \
"
