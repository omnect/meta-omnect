FILESEXTRAPATHS:prepend := "${THISDIR}/fintek-f75111:"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM="\
  file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
"

## use SRC_URI as below if you wanto to use pre-compiled binary
#SRC_URI = "\
#        file://CIO_Utility_Console_L_Bin_v${PV}.zip \
#"

# otherwise the following SRC_URI is needed
# (note the patch which is required to avoid a dupulicated symbol which is
# defined in main.c as well as f75111.c, the latter being part of the f75111.a
# library together with the SMBus stuff in SMBus/SMBus.c)
SRC_URI = "\
        file://CIO_Utility_Console_L_Src_v${PV}.zip \
        file://console-util-main.patch \
"

# if you want to use the pre-compiled binary S needs to be defined as below
# and do_compile would become a nop
# S = "${WORKDIR}/CIO_Utility_Console_L_Bin_v${PV}"
#
# do_compile() {
#     :
# }

# to really build from sources the following setting for S and do_compile() is
# required
S = "${WORKDIR}/CIO_Utility_Console_L_Src_v${PV}/CIO_Utility_Console"

do_compile() {
    # at first create library
    $CC -c SMBus/SMBus.c -o SMBus.o
    $CC -c f75111.c -o f75111.o
    $AR rvs libf75111.a f75111.o SMBus.o

    # now compile main file
    $CC -c main.c -o main.o

    # now link everything together
    $CC -v -static -pthread  main.o -o CIO_Utility_Console -l pthread -L. -l f75111
}

# next line is only necessary if binary tool from binary archive gets installed
# INSANE_SKIP:${PN} += "already-stripped"

do_install() {
    install -D -m 0755 ./CIO_Utility_Console ${D}${sbindir}/CIO_Utility_Console
}

FILES:${PN} = "${sbindir}/CIO_Utility_Console"