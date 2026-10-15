#
#  omnect initramfs image
#

inherit image

IMAGE_FSTYPES = "${OMNECT_INITRAMFS_FSTYPE}"

# reset IMAGE_FEATURES var for initramfs
IMAGE_FEATURES = ""
IMAGE_LINGUAS = ""
KERNELDEPMODDEPEND = ""
IMAGE_NAME_SUFFIX = ""
