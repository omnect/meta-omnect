# If we install iotedge we have to add 'virtualization' to 'DISTRO_FEATURES'.
# We can not do this via
# 'DISTRO_FEATURES_append = "${@bb.utils.contains('DISTRO_FEATURES', 'iotedge', ' virtualization', '', d)}"'
# in layer.conf. We then get a recursion error. Also we can not access
# 'DISTRO_FEATURES' directly, since it is not available at layer.conf load
# time. We delay using this special bbclass.
DISTRO_FEATURES_append = " virtualization"
