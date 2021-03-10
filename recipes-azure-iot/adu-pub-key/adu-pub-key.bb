# Generates and copies/installs the public key .pem file
# used to validate the signatures of images.

LICENSE="CLOSED"

ADUC_KEY_DIR = "/adukey"

DEPENDS = "openssl-native"

# Generated RSA key with password using command:
# openssl genrsa -aes256 -passout file:priv.pass -out priv.pem

# Generate the public key file using openssl, private key, and password file.
do_compile() {
    openssl rsa -in ${ADUC_PRIVATE_KEY} -passin file:${ADUC_PRIVATE_KEY_PASSWORD} -out public.pem -outform PEM -pubout
}

# Install the public key file to ADUC_KEY_DIR
do_install() {
    install -d ${D}${ADUC_KEY_DIR}
    install -m 0444 public.pem ${D}${ADUC_KEY_DIR}/public.pem
}

FILES_${PN} += "${ADUC_KEY_DIR}/public.pem"

inherit allarch
