# Reads per-machine capabilities from files/device_caps/${MACHINE}.json so that
# DISTRO_FEATURES (and any recipe) can gate on the same file used at runtime.
def omnect_device_cap(d, key):
    import json, os
    path = os.path.join(d.getVar('LAYERDIR_omnect'), 'files',
                        'device_caps', '%s.json' % d.getVar('MACHINE'))
    # re-trigger parse when the JSON changes
    bb.parse.mark_dependency(d, path)
    try:
        with open(path) as f:
            return json.load(f).get(key, '')
    except (IOError, ValueError):
        return ''
