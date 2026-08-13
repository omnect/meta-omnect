FILESEXTRAPATHS:prepend := "${THISDIR}/linux:"

SRC_URI += "file://0001-feat-linux-imx-added-ramoops-for-tauril2.patch"

# Both linux-common-secureboot.inc's do_sign() ("secureboot" in
# d.getVar('DISTRO_FEATURES')) and linux-phytec-fitimage.inc's
# do_deploy:append() ("echo ${DISTRO_FEATURES} | grep -wq secureboot")
# read the *raw* DISTRO_FEATURES string directly. BitBake's vardep
# scanner therefore ties do_sign/do_deploy's taskhash to the ENTIRE
# feature list, not just secureboot membership. Because do_compile,
# do_configure, do_kernel_metadata etc. have no sstate object of their
# own, any unrelated DISTRO_FEATURES churn (e.g. wifi/bluetooth flags
# driven by device_caps.json, see commit e1ad988) forces the whole
# kernel/module compile lineage to re-run for real, while
# do_package_write_ipk's own (unrelated) signature stays cache-hit --
# producing a kernel/module version mismatch (observed 2026-07-10,
# build 107 of omnect-os-build/tauril2 gateway-devel). Narrow the
# tracked dependency to just the boolean outcome these tasks actually
# care about.
SECUREBOOT_ENABLED := "${@bb.utils.contains('DISTRO_FEATURES', 'secureboot', '1', '0', d)}"
do_sign[vardeps] += "SECUREBOOT_ENABLED"
do_sign[vardepsexclude] += "DISTRO_FEATURES"
do_deploy[vardeps] += "SECUREBOOT_ENABLED"
do_deploy[vardepsexclude] += "DISTRO_FEATURES"
