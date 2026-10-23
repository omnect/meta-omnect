import json
import os
import bb


def _find_json_path(d, machine):
    '''
    helper function to find capability json file for given machine
    '''
    bblayers_str = d.getVar('BBLAYERS') or ''
    for layer_path in bblayers_str.split():
        json_path = os.path.join(layer_path, 'files', 'device_caps', f"{machine}.json")
        # Mark every candidate, not just the hit, so that bitbake re-parses
        # when the file is added to a layer that comes earlier in BBLAYERS.
        # Non-existent paths are recorded with mtime 0, so creating them later
        # invalidates the parse cache. Bitbake deduplicates the dependencies.
        bb.parse.mark_dependency(d, json_path)
        if os.path.exists(json_path):
            return json_path
    return None


def _load_device_caps(json_path):
    """
    Read the capability dictionary from the given JSON file.
    """
    try:
        with open(json_path, 'r') as f:
            data = json.load(f)
    except (OSError, ValueError) as e:
        bb.fatal(f"device_caps: Failed to read or parse JSON file {json_path}: {e}")

    if not isinstance(data, dict):
        bb.fatal(f"device_caps: JSON file {json_path} is malformed. "
                 "Top-level element must be a dictionary.")

    return data


def get_cap(d, cap_name):
    """
    public API for recipes: returns a capability's value; any error results in
    a bitbake parse abortion with a fatal message.
    """
    machine = d.getVar('MACHINE')
    if not machine:
        bb.fatal("device_caps: MACHINE variable is not set. Cannot determine device capabilities.")

    json_path = _find_json_path(d, machine)
    if not json_path:
        bb.fatal(f"device_caps: No device capability JSON file found for MACHINE '{machine}' in any active layer.")

    machine_caps = _load_device_caps(json_path)

    # we consider a non-existent capability name (i.e. dict key) to be an
    # error, because every capability must be present in all target device
    # files
    if cap_name not in machine_caps:
        available_keys = ", ".join(machine_caps.keys()) if machine_caps else "None"
        bb.fatal(
            f"device_caps: Requested unknown capability '{cap_name}'. "
            f"Please check for typos or add it to '{json_path}'.\n"
            f"Available capabilities in this file: [{available_keys}]"
        )

    return str(machine_caps[cap_name])
