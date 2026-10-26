import json
import os
import bb

KNOWN_CAPS = ('3g', 'bluetooth', 'tpm2', 'wifi')
VALID_CAP_VALUES = ('no', 'optional', 'yes')
ENABLED_CAP_VALUES = ('optional', 'yes')


def _rel_json_path(machine):
    return os.path.join('files', 'device_caps', f"{machine}.json")


def _find_json_path(d, machine):
    # Mark the misses too: bitbake stores them with mtime 0, so adding the file
    # to a layer earlier in BBLAYERS invalidates the parse cache.
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

    # every capability has to be set for every machine, so that adding one does
    # not silently leave some machines behind
    missing = [cap for cap in KNOWN_CAPS if cap not in data]
    if missing:
        bb.fatal(f"device_caps: JSON file {json_path} does not set the capabilities "
                 f"{', '.join(missing)}. Expected all of: {', '.join(KNOWN_CAPS)}.")

    for cap in KNOWN_CAPS:
        if data[cap] not in VALID_CAP_VALUES:
            bb.fatal(f"device_caps: Capability '{cap}' in '{json_path}' has invalid value "
                     f"{data[cap]!r} (expected one of {', '.join(VALID_CAP_VALUES)}).")

    return data


def get_cap(d, cap_name):
    """
    Return the value of cap_name from the device_caps JSON of MACHINE; call
    bb.fatal() on any error. See doc/device_caps.md.
    """
    if cap_name not in KNOWN_CAPS:
        bb.fatal(f"device_caps: Requested unknown capability '{cap_name}'. "
                 f"Please check for typos or add it to KNOWN_CAPS and to every "
                 f"device_caps JSON file.\nKnown capabilities: {', '.join(KNOWN_CAPS)}")

    machine = d.getVar('MACHINE')
    if not machine:
        bb.fatal("device_caps: MACHINE variable is not set. Cannot determine device capabilities.")

    json_path = _find_json_path(d, machine)
    if not json_path:
        bb.fatal(f"device_caps: No device capability JSON file found for MACHINE '{machine}'. "
                 f"Expected '{_rel_json_path(machine)}' in one of the layers in BBLAYERS.")

    return _load_device_caps(json_path)[cap_name]
