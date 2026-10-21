import json
import os
import bb

# global capabilities cache
_CACHED_CAPS = {}

def _find_json_path(d, machine):
    '''
    helper function to find capability json file for given machine
    '''
    bblayers_str = d.getVar('BBLAYERS') or ''
    for layer_path in bblayers_str.split():
        json_path = os.path.join(layer_path, 'files', 'device_caps', f"{machine}.json")
        if os.path.exists(json_path):
            # tell bitbake the dependency on this file for proper rebuilding
            # note that bitbake deduplicates in case the path is already in
            # dependency list
            bb.parse.mark_dependency(d, json_path)
            return json_path
    return None

def _load_device_caps_for_machine(d, machine, json_path):
    """
    Read capabilities from JSON file and store them in array for retrieval by
    get_function.
    """
    global _CACHED_CAPS

    try:
        current_mtime = os.path.getmtime(json_path)
        with open(json_path, 'r') as f:
            data = json.load(f)
            if isinstance(data, dict):
                _CACHED_CAPS[machine] = {
                    "caps": data,
                    "mtime": current_mtime,
                    "path": json_path
                }
                return
            else:
                bb.fatal(f"mycustom: JSON file {json_path} is malformed. Top-level element must be a dictionary.")
    except (json.JSONDecodeError, IOError) as e:
        bb.fatal(f"mycustom: Failed to read or parse JSON file {json_path}: {e}")

def get_cap(d, cap_name):
    """
    public API for recipes: returns a capability's value if it exists, an empty
    string otherwise.
    NOTE: the empty string is also returned in case the expected file doesn't
    exist!.
    """
    global _CACHED_CAPS
    
    machine = d.getVar('MACHINE')
    if not machine:
        bb.fatal("device_caps: MACHINE variable is not set. Cannot determine device capabilities.")

    json_path = _find_json_path(d, machine)
    if not json_path:
        bb.fatal(f"device_caps: No device capability JSON file found for MACHINE '{machine}' in any active layer.")

    # do we have a cached JSON file and is it perhaps outdated?
    current_mtime = os.path.getmtime(json_path)
    if machine in _CACHED_CAPS:
        cached_mtime = _CACHED_CAPS[machine]["mtime"]
        if current_mtime != cached_mtime:
            # invalidate cache due to changed file
            del _CACHED_CAPS[machine]

    # fill the entry if not yet present
    if machine not in _CACHED_CAPS:
        _load_device_caps_for_machine(d, machine, json_path)

    # we consider a non-existent capability name (i.e. dict key) to be an
    # error, because every capability must be present in all target device
    # files
    machine_caps = _CACHED_CAPS[machine]["caps"]
    loaded_file_path = _CACHED_CAPS[machine]["path"]
    if cap_name not in machine_caps:
        available_keys = ", ".join(list(machine_caps.keys())) if machine_caps else "None"
        bb.fatal(
            f"mycustom: Requested unknown capability '{cap_name}'. "
            f"Please check for typos or add it to '{loaded_file_path}'.\n"
            f"Available capabilities in this file: [{available_keys}]"
        )
 
    return machine_caps[cap_name]

import os
import json

_OMNECT_CAPABILITIES = None
