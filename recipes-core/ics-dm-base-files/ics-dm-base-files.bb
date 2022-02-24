SUMMARY = "ICS DM Base Files"
DESCRIPTION = "Provide ICS DM Base Files."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "\
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
"

SRC_URI = "\
    file://etc/sudoers.d/001_ics-dm \
    file://etc/profile.d/ics-dm_profile.sh \
"

FILES:${PN} = "\
    /etc/sudoers.d/001_ics-dm \
    /etc/profile.d/ics-dm_profile.sh \
    /mnt/cert \
    /mnt/data \
    /mnt/etc \
    /mnt/factory \
    ${libdir}/tmpfiles.d/ics-dm-base-files.conf \
    /var/lib \
    ${exec_prefix}/local \
"

do_install() {
    install -d ${D}/etc/sudoers.d/
    install -d ${D}/etc/profile.d/
    install -m 0644 ${WORKDIR}/etc/sudoers.d/001_ics-dm ${D}/etc/sudoers.d/
    install -m 0644 ${WORKDIR}/etc/profile.d/ics-dm_profile.sh ${D}/etc/profile.d/

    # install mountpoints
    install -d -D ${D}/mnt/cert \
    install -d -D ${D}/mnt/data \
    install -d -D ${D}/mnt/etc \
    install -d -D ${D}/mnt/factory \
    install -d -D ${D}/var/lib \
    install -d -D ${D}${exec_prefix}/local

    # create tmpfiles.d entry to (re)create permissions on injectables
    install -d ${D}${libdir}/tmpfiles.d
    echo "z /etc 0775 root root -"              >> ${D}${libdir}/tmpfiles.d/ics-dm-base-files.conf
    echo "z /etc/hosts 0664 root root -"        >> ${D}${libdir}/tmpfiles.d/ics-dm-base-files.conf
    echo "z /etc/hostname 0664 root root -"     >> ${D}${libdir}/tmpfiles.d/ics-dm-base-files.conf
    echo "z /mnt/cert/ca 0755 root root -"      >> ${D}${libdir}/tmpfiles.d/ics-dm-base-files.conf
    echo "z /mnt/cert/priv 0755 root root -"    >> ${D}${libdir}/tmpfiles.d/ics-dm-base-files.conf
}

#  add factory_reset group
inherit useradd
USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM:${PN} = "-r factory_reset"
