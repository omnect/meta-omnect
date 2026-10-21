import json
import os
import bb

# global capabilities cache
_CACHED_CAPS_BY_MACHINE = {}
# remember capabilities file, also to check that on was indeed found
_LOADED_FILE_PATHS = {}

def _load_device_caps(d, machine):
    """
    Read capabilities from JSON file and store them in array for retrieval by
    get_function.
    """
    global _CACHED_CAPS_BY_MACHINE
    global _LOADED_FILE_PATHS

    # make variable an empty dict as default
    _CACHED_CAPS_BY_MACHINE[machine] = None

    bblayers_str = d.getVar('BBLAYERS') or ''
    
    if not machine:
        bb.fatal("device_caps: MACHINE variable is not set yet during load.")
        return

    # search layers for relevant files
    for layer_path in bblayers_str.split():
        json_path = os.path.join(layer_path, 'files', 'device_caps', f"{machine}.json")
        bb.debug(1, f"device_caps: checking for file {json_path}")
        if os.path.exists(json_path):
            try:
                with open(json_path, 'r') as f:
                    data = json.load(f)
                    if isinstance(data, dict):
                        _CACHED_CAPS_BY_MACHINE[machine] = data
                        # there's only one matching file, so we're done here
                        _LOADED_FILE_PATHS[machine] = json_path
                        return
                    else:
                        bb.fatal(f"device_caps: JSON file {json_path} does not contain a top-level dictionary.")
            except (json.JSONDecodeError, IOError) as e:
                bb.fatal(f"device_caps: Failed to read or parse {json_path}: {e}")
                return

def get_cap(d, cap_name):
    """
    public API for recipes: returns a capability's value if it exists, an empty
    string otherwise.
    NOTE: the empty string is also returned in case the expected file doesn't
    exist!.
    """
    global _CACHED_CAPS_BY_MACHINE, _LOADED_FILE_PATHS
    
    machine = d.getVar('MACHINE')
    if not machine:
        bb.fatal("device_caps: MACHINE variable is not set. Cannot determine device capabilities.")
    # fill the entry upon first invocation
    if machine not in _CACHED_CAPS_BY_MACHINE:
        _load_device_caps(d, machine)
        
    # we expect to have a capabilities file for every target device
    if _CACHED_CAPS_BY_MACHINE[machine] is None:
        bb.fatal(f"device_caps: No device capability JSON file found for MACHINE '{d.getVar('MACHINE')}' in any active layer.")

    # we consider a non-existent capability name (i.e. dict key) to be an
    # error, because every capability must be present in all target device
    # files
    machine_caps = _CACHED_CAPS_BY_MACHINE[machine]
    if cap_name not in machine_caps:
        available_keys = ", ".join(list(machine_caps.keys())) if machine_caps else "None"
        bb.fatal(
            f"mycustom: Requested unknown capability '{cap_name}'. "
            f"Please check for typos or add it to '{_LOADED_FILE_PATHS[machine]}'.\n"
            f"Available capabilities in this file: [{available_keys}]"
        )
 
    return machine_caps[cap_name]

import os
import json

_OMNECT_CAPABILITIES = None
