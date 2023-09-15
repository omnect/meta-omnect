FILESEXTRAPATHS:prepend := "${LAYERDIR_omnect}/files/:"

# for usage in intramfs flash-mode only

LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
"

SRC_URI = "\
    file://grubenv \
"

do_install[depends] += "grub-efi:do_deploy"

do_install() {
	install -m 0644 -D ${WORKDIR}/grubenv ${D}${sysconfdir}/omnect/grubenv.in
}
