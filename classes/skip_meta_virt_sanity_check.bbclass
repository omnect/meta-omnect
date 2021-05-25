# If this file is added to USER_CLASSES we suppress a warning from
# meta-virtualization.
# E.g. ics-dm-os uses it when DISTRO_FEATURE `iotedge` is not set.
# In this case ics-dm-os has no dependency to recipes which require
# `virtualization` to be set.
SKIP_META_VIRT_SANITY_CHECK = "1"
