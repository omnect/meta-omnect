import json
import os
import bb

# the only values a capability may take in a device_caps JSON file
VALID_CAP_VALUES = ('no', 'optional', 'yes')


def _rel_json_path(machine):
    return os.path.join('files', 'device_caps', f"{machine}.json")


def _find_json_path(d, machine):
    # bb.utils.which() keeps the BBLAYERS order and reports every path it
    # tried, the same way bb.parse.resolve_file() uses it. Marking the misses
    # matters too: bitbake records them with mtime 0, so adding the file to a
    # layer earlier in BBLAYERS invalidates the parse cache as well.
    bblayers = ':'.join((d.getVar('BBLAYERS') or '').split())
    json_path, tried = bb.utils.which(bblayers, _rel_json_path(machine), history=True)
    for path in tried:
        bb.parse.mark_dependency(d, path)
    return json_path


def _load_device_caps(json_path):
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
    Return the value of cap_name from the device_caps JSON of MACHINE; call
    bb.fatal() on any error.

    Recipes must read a capability through its OMNECT_DEVICE_CAP_* variable, or
    through another variable carrying a [vardepvalue] flag, rather than calling
    this function from task code: only that flag puts the JSON value into the
    task signature. A task calling get_cap() directly hashes just this
    function's source and MACHINE, so it would still be served from sstate
    after a capability value changed.
    """
    machine = d.getVar('MACHINE')
    if not machine:
        bb.fatal("device_caps: MACHINE variable is not set. Cannot determine device capabilities.")

    json_path = _find_json_path(d, machine)
    if not json_path:
        bb.fatal(f"device_caps: No device capability JSON file found for MACHINE '{machine}'. "
                 f"Expected '{_rel_json_path(machine)}' in one of the layers in BBLAYERS.")

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

    # only the requested capability is validated, so that extra keys such as a
    # comment entry remain possible
    value = machine_caps[cap_name]
    if value not in VALID_CAP_VALUES:
        bb.fatal(f"device_caps: Capability '{cap_name}' in '{json_path}' has invalid value "
                 f"{value!r} (expected one of {', '.join(VALID_CAP_VALUES)}).")

    return value
