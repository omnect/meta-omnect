# INCOMPATIBLE_LICENSE_EXCEPTIONS is matched per *package* name, not per recipe
# (see oe.license.apply_pkg_license_exception: it tests "<pkg>:<license>"). So an
# entry like "bash:GPL-3.0-or-later" only whitelists the main "bash" package while
# every sub-package it produces (bash-dev, bash-doc, bash-src, bash-dbg,
# bash-staticdev, ...) still carries the incompatible license and is excluded at
# parse time by base.bbclass' oe.license.skip_incompatible_package_licenses().
#
# This class expands each existing exception entry to cover *all* packages produced
# by the recipe that owns the named package, so a single line in
# INCOMPATIBLE_LICENSE_EXCEPTIONS keeps covering the whole recipe.

def omnect_license_exception_subpkgs(d):
    packages = (d.getVar('PACKAGES') or '').split()
    if not packages:
        return ''

    # Read the value unexpanded to avoid recursing into our own :append below.
    # Concrete kas entries are literal; the "${@...}" append token contains '$'
    # and is skipped.
    raw = d.getVar('INCOMPATIBLE_LICENSE_EXCEPTIONS', False) or ''

    extra = []
    for entry in raw.split():
        if ':' not in entry or '$' in entry:
            continue
        name, lic = entry.split(':', 1)
        # Only the recipe that actually produces the named package expands it.
        if name in packages:
            extra += ['%s:%s' % (pkg, lic) for pkg in packages]

    return ' '.join(sorted(set(extra)))

# Expanded whenever INCOMPATIBLE_LICENSE_EXCEPTIONS is read; the relevant reader is
# base.bbclass' parse-time check, so PACKAGES holds the statically declared
# sub-packages of the recipe being parsed.
INCOMPATIBLE_LICENSE_EXCEPTIONS:append = " ${@omnect_license_exception_subpkgs(d)}"
