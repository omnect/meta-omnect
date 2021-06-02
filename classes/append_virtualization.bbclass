# If we install iotedge we have to add 'virtualization' to 'DISTRO_FEATURES'.
# We can not do this via
# 'DISTRO_FEATURES_append = "${@bb.utils.contains('DISTRO_FEATURES', 'iotedge', ' virtualization', '', d)}"'
# in a conf file. We then get a recursion error. Also we can not access
# 'DISTRO_FEATURES' directly, since it is not available at conf file load
# time. We delay using this special bbclass and the _append operator.
DISTRO_FEATURES_append = " virtualization"
