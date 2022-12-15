SUMMARY = "omnect Base Files"
DESCRIPTION = "Provide omnect Base Files."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "\
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
"

SRC_URI = "\
    file://etc/bashrc \
    file://etc/profile.d/omnect_profile.sh \
    file://etc/profile.d/omnect_prompt.sh \
    file://etc/sudoers.d/001_omnect \
    file://usr/bin/omnect_get_deviceid.sh \
    file://usr/bin/omnect_get_tpm_reg_info.sh \
"

RDEPENDS:${PN} += "\
  bash \
"

FILES:${PN} = "\
    ${exec_prefix}/local \
    ${libdir}/tmpfiles.d/omnect-base-files.conf \
    /etc/bashrc \
    /etc/profile.d/omnect_profile.sh \
    /etc/profile.d/omnect_prompt.sh \
    /etc/sudoers.d/001_omnect \
    /mnt/cert \
    /mnt/data \
    /mnt/etc \
    /mnt/factory \
    /usr/bin/omnect_get_deviceid.sh \
    /usr/bin/omnect_get_tpm_reg_info.sh \
    /var/lib \
"

do_install() {
    install -m 0644 -D ${WORKDIR}/etc/bashrc ${D}/etc/bashrc
    install -m 0755 -D ${WORKDIR}/usr/bin/omnect_get_deviceid.sh ${D}/usr/bin/omnect_get_deviceid.sh
    install -m 0755 -D ${WORKDIR}/usr/bin/omnect_get_tpm_reg_info.sh ${D}/usr/bin/omnect_get_tpm_reg_info.sh
    install -m 0644 -D ${WORKDIR}/etc/sudoers.d/001_omnect ${D}/etc/sudoers.d/001_omnect
    install -m 0644 -D ${WORKDIR}/etc/profile.d/omnect_profile.sh ${D}/etc/profile.d/omnect_profile.sh
    install -m 0644 -D ${WORKDIR}/etc/profile.d/omnect_prompt.sh ${D}/etc/profile.d/omnect_prompt.sh

    # install mountpoints
    install -d -D ${D}/mnt/cert \
    install -d -D ${D}/mnt/data \
    install -d -D ${D}/mnt/etc \
    install -d -D ${D}/mnt/factory \
    install -d -D ${D}/var/lib \
    install -d -D ${D}${exec_prefix}/local

    # create tmpfiles.d entry to (re)create permissions on injectables
    install -d ${D}${libdir}/tmpfiles.d
    echo "z /etc 0775 root root -"              >> ${D}${libdir}/tmpfiles.d/omnect-base-files.conf
    echo "z /etc/hosts 0664 root root -"        >> ${D}${libdir}/tmpfiles.d/omnect-base-files.conf
    echo "z /etc/hostname 0664 root root -"     >> ${D}${libdir}/tmpfiles.d/omnect-base-files.conf
    echo "z /mnt/cert/ca 0755 root root -"      >> ${D}${libdir}/tmpfiles.d/omnect-base-files.conf
    echo "z /mnt/cert/priv 0755 root root -"    >> ${D}${libdir}/tmpfiles.d/omnect-base-files.conf
}

#  add omnect_device_service group
inherit useradd
USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM:${PN} = "-r omnect_device_service"
