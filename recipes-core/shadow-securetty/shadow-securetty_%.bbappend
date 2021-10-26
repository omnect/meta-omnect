do_install_append () {
    # debug-tweaks not set
    if [ "${@bb.utils.contains("IMAGE_FEATURES", "debug-tweaks", "", "securetty",d)}" = "securetty" ]; then

        # disable direct access to serial console for user root
        sed -i "s|\(^ttyS[0-9]\+$\)|#\1|g" ${D}${sysconfdir}/securetty

        # disable direct access to graphical console for user root
        sed -i "s|\(^tty[0-9]\+$\)|#\1|g" ${D}${sysconfdir}/securetty
    fi
}
