do_install:append() {
    sed -i 's/^export PS1=\(.*\)$/[ -z \"\$PS1\" ] \&\& export PS1=\1/' ${D}/etc/skel/.bashrc
}
