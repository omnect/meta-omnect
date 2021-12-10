FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# we have to append here, if we add it via += the fragment gets overwritten by
# phytec's docker.cfg fragment.
# docker.cfg activates unix domain sockets as module, but we need it compiled
# into kernel for our initramfs.
SRC_URI:append = "file://unix_domain_sockets.cfg"
