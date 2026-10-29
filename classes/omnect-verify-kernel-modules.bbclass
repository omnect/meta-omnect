# Guards against the kernel Image and the shipped kernel-modules package
# being built from different kernel source states.
#
# Background: BitBake's per-task sstate/setscene mechanism can restore
# do_package_write_ipk/do_populate_sysroot for the kernel recipe from an
# older cached object while do_compile/do_sign/do_deploy execute fresh in
# the SAME build - each decision is made independently, based only on
# whether a given task's own declared taskhash matches something already
# cached. For linux-yocto style kernel recipes this is compounded by the
# kernel-yocto SCC/KMETA merge tree embedding a non-reproducible
# git-describe hash into LOCALVERSION/vermagic that BitBake's signatures
# never track - so even a taskhash match doesn't guarantee identical
# actual output.
#
# When this happens, the produced image boots a kernel whose modules
# directory (embedded LOCALVERSION) doesn't match the kernel's own
# reported version, and modules silently fail to load
# ("modprobe: ERROR: ... invalid module format" / similar). See incident
# 2026-07-10, build 107 of omnect-os-build/tauril2,gateway-devel, and
# meta-omnect PR #670 for the part of the root cause that could be fixed
# by narrowing a spurious do_sign/do_deploy signature dependency. This
# class catches the *general* class of mismatch (any cause) at image
# build time instead of letting it reach a device silently.
#
# Note: relies on the "Linux version ..." banner string being present as
# plain ASCII inside the deployed kernel image blob (true for the
# uncompressed arm64 "Image" format used by our machines; would need
# adjustment - e.g. decompressing first - for machines using a
# compressed KERNEL_IMAGETYPE such as zImage/uImage with gzip/lz4).

python omnect_verify_kernel_module_consistency() {
    import glob
    import re

    modules_dirs = glob.glob(d.expand("${IMAGE_ROOTFS}/lib/modules/*"))
    if len(modules_dirs) != 1:
        bb.warn("omnect-verify-kernel-modules: expected exactly one "
                "${IMAGE_ROOTFS}/lib/modules/<version> directory, found "
                "%d - skipping consistency check" % len(modules_dirs))
        return
    modules_version = os.path.basename(modules_dirs[0].rstrip("/"))

    deploydir = d.getVar("DEPLOY_DIR_IMAGE")
    candidates = sorted(
        glob.glob(os.path.join(deploydir, "fitImage-*"))
        + glob.glob(os.path.join(deploydir, "Image-*"))
        + glob.glob(os.path.join(deploydir, "Image")),
        key=os.path.getmtime,
        reverse=True,
    )
    candidates = [c for c in candidates if os.path.isfile(c) and not os.path.islink(c)]
    if not candidates:
        bb.warn("omnect-verify-kernel-modules: no deployed kernel/fitImage "
                "found under %s - skipping consistency check" % deploydir)
        return

    kernel_version = None
    with open(candidates[0], "rb") as f:
        data = f.read()
    m = re.search(rb"Linux version (\S+)", data)
    if m:
        kernel_version = m.group(1).decode()

    if kernel_version is None:
        bb.warn("omnect-verify-kernel-modules: could not find a 'Linux "
                "version' banner in %s - skipping consistency check "
                "(likely a compressed KERNEL_IMAGETYPE not yet supported "
                "by this check)" % candidates[0])
        return

    if kernel_version != modules_version:
        bb.fatal(
            "Kernel/modules version mismatch detected!\n"
            "  deployed kernel (%s) reports: %s\n"
            "  /lib/modules directory:       %s\n"
            "The kernel Image and the packaged kernel modules were built "
            "from different kernel source states (e.g. a stale sstate "
            "cache hit for do_package_write_ipk/do_populate_sysroot while "
            "the kernel itself was freshly rebuilt in the same build). "
            "Refusing to produce an image whose modules would fail to "
            "load at runtime." % (os.path.basename(candidates[0]),
                                  kernel_version, modules_version))
}

IMAGE_POSTPROCESS_COMMAND:append = " omnect_verify_kernel_module_consistency;"
