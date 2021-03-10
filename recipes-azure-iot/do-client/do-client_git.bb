# Build and install Delivery Optimization Client and SDK.
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

DESCRIPTION = "Delivery Optimization Client"
HOMEPAGE = "https://github.com/microsoft/do-client.git"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=ee51f94efd0db5b258b5b1b8107fea02"

SRC_URI = " \
    git://github.com/microsoft/do-client.git;protocol=https;branch=main;tag=0.6.0 \
    file://fix-linking.patch \
    file://do-client.service \
    "

S = "${WORKDIR}/git"

DEPENDS = "boost cpprest msft-gsl libproxy"

inherit cmake features_check systemd

EXTRA_OECMAKE += "-DCMAKE_BUILD_TYPE=Release"
EXTRA_OECMAKE += "-DDO_BUILD_TESTS=OFF"
EXTRA_OECMAKE += "-DDO_PROXY_SUPPORT=ON"
EXTRA_OECMAKE += "-DDO_INCLUDE_AGENT=ON"

do_install_append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/do-client.service ${D}${systemd_system_unitdir}
}

SYSTEMD_SERVICE_${PN} = "do-client.service"
FILES_${PN} += "${systemd_system_unitdir}/do-client.service"
REQUIRED_DISTRO_FEATURES = "systemd"
