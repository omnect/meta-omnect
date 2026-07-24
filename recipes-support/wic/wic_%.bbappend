FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# wrynose split wic out of oe-core into this standalone recipe, so meta-omnect's ESP
# population (formerly kas/patches/oe_bootimg_efi_wic.patch against the in-tree
# scripts/lib/wic) now has to be a recipe patch. Only the bootimg-efi plugin is
# touched, which only genericx86-64 (secure boot) uses; inert for u-boot machines.
SRC_URI += "file://populate-esp-from-omnect-secure-boot-artifacts.patch"
