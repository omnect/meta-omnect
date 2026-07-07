# Reads per-machine capabilities from <layer>/files/device_caps/${MACHINE}.json so
# that DISTRO_FEATURES (and any recipe) can gate on the same file installed at
# runtime by base-files. Searches all layers (like base-files' FILESEXTRAPATHS),
# not just meta-omnect, so lab machines whose JSON lives in another layer resolve.
def omnect_device_cap(d, key):
    import json, os
    machine = d.getVar('MACHINE')
    for layer in (d.getVar('BBLAYERS') or '').split():
        path = os.path.join(layer, 'files', 'device_caps', '%s.json' % machine)
        # mark even non-existent candidates: creating one later re-triggers parse
        bb.parse.mark_dependency(d, path)
        if os.path.exists(path):
            try:
                with open(path) as f:
                    return json.load(f).get(key, '')
            except (IOError, ValueError):
                return ''
    return ''
