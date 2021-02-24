do_install_append() {
    sed -i -E "s/^After=(.*)/After=\1 var-lib.mount/" ${D}/lib/systemd/system/docker.service
}
