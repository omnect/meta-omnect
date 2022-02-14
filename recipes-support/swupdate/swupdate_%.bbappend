FILESEXTRAPATHS_append := "${THISDIR}/${PN}:"

DEPENDS += "openssl-native"

PACKAGECONFIG_CONFARGS = ""

inherit useradd

# Generated RSA key file (SWUPDATE_PRIVATE_KEY=priv.pem) with password
# (SWUPDATE_PASSWORD_FILE=priv.pass) using command:
#
# openssl genrsa -aes256 -passout file:priv.pass -out priv.pem

# Generate the public key file using openssl, private key, and password file.
do_compile:append() {
    openssl rsa -in ${SWUPDATE_PRIVATE_KEY} -passin file:${SWUPDATE_PASSWORD_FILE} -out public.pem -outform PEM -pubout
}

do_install:append() {
  if [ -z "${HW_REV}" ];then bb_error "HW_REV not set" ;exit 1; fi
  if [ -z "${MACHINE}" ];then bb_error "MACHINE not set";exit 1; fi
  if [ -z "${SOFTWARE_NAME}" ];then bb_error "SOFTWARE_NAME not set"; exit 1; fi
  if [ -z "${SOFTWARE_VERSION}" ];then bb_error "SOFTWARE_VERSION not set"; exit 1; fi

  echo "${MACHINE} ${HW_REV}" >> ${D}/${sysconfdir}/hwrevision
  echo "${SOFTWARE_NAME} ${SOFTWARE_VERSION}" >> ${D}/${sysconfdir}/sw-versions

  sed -i 's/^\[Socket\]/\[Socket\]\nSocketUser=adu\nSocketGroup=adu/' ${D}${systemd_system_unitdir}/swupdate.socket

  # swupdate pub key
  install -m 0444 public.pem -D ${D}${datadir}/swupdate/public.pem
}

FILES_${PN} += " \
    ${datadir}/swupdate/public.pem \
    ${sysconfdir}/hwrevision \
    ${sysconfdir}/sw-versions \
"

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM_${PN} = "-r adu"
