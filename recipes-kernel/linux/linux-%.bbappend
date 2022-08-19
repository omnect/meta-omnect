FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# always link overlayfs to linux kernel, instead of using loadable module,
# as enforced by the layer meta-virtualization, which is not always present
SRC_URI += " \
    file://enable-overlayfs.cfg \
"
