FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# The MBIM device-caps handler frees an uninitialised autofree pointer on its
# error path, so a modem whose port disappears during setup corrupts the heap
# and aborts the daemon.
# TODO: remove me, as soon as the recipe is past 1.24.2 and carries the fix
SRC_URI += "file://0001-broadband-modem-mbim-initialize-autofreed-string-to-N.patch"
