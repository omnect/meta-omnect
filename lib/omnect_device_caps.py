# Helper for reading per-machine capabilities from device_caps.json, usable in
# configuration-level ${@...} expansions (e.g. DISTRO_FEATURES).
#
# A `def` in a .bbclass is NOT in scope for config-level ${@...} (DISTRO_FEATURES
# is force-expanded very early via USER_CLASSES -> INHERIT, before such a class is
# in scope). A module under the layer's lib/ IS importable at that point, because
# bitbake puts every layer's lib/ on sys.path (BBPATH). Call it as
#   ${@__import__('omnect_device_caps').device_cap(d, 'wifi')}
# which needs no INHERIT and no OE_IMPORTS ordering.

import json
import os

import bb


def device_cap(d, key):
    """Return the device_caps.json value for `key` on the current MACHINE, or ''.

    Searches every layer's files/device_caps/<MACHINE>.json (mirroring how
    base-files installs the runtime copy via FILESEXTRAPATHS), first match wins.
    A missing file, malformed JSON, or missing key returns '' — callers enable a
    feature only on the explicit 'optional'|'yes' values, so this is fail-safe.
    """
    machine = d.getVar('MACHINE')
    for layer in (d.getVar('BBLAYERS') or '').split():
        path = os.path.join(layer, 'files', 'device_caps', '%s.json' % machine)
        # register as a parse dependency so editing the JSON re-triggers parse
        bb.parse.mark_dependency(d, path)
        if os.path.exists(path):
            try:
                with open(path) as f:
                    return json.load(f).get(key, '')
            except (IOError, ValueError):
                return ''
    return ''
