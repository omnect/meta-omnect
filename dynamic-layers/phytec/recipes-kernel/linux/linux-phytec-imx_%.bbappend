FILESEXTRAPATHS:prepend := "${THISDIR}/linux:"

SRC_URI += "file://0001-feat-linux-imx-added-ramoops-for-tauril2.patch"

# Fix sporadic/console-timing-dependent eth0 naming race on Tauri-L: build the
# on-board Intel I210 (igb) as a module so FEC1 wins "eth0" and igb gets "eth1".
SRC_URI += "file://igb-as-module.cfg"
