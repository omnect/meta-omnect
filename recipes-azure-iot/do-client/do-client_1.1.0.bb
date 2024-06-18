# Build and install Delivery Optimization Client and SDK.
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

DESCRIPTION = "Delivery Optimization Client"
HOMEPAGE = "https://github.com/microsoft/do-client.git"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=ee51f94efd0db5b258b5b1b8107fea02"

SRC_URI = " \
    git://github.com/microsoft/do-client.git;protocol=https;tag=v1.1.0;nobranch=1; \
    file://do-client.conf \
    file://do-client.service \
"

PV .= "+${SRCPV}"

S = "${WORKDIR}/git"

DEPENDS = "curl boost msft-gsl libproxy"

inherit cmake systemd useradd

EXTRA_OECMAKE += "-DCMAKE_BUILD_TYPE=Release"
EXTRA_OECMAKE += "-DDO_BUILD_TESTS=OFF"
EXTRA_OECMAKE += "-DDO_PROXY_SUPPORT=ON"
EXTRA_OECMAKE += "-DDO_INCLUDE_AGENT=ON"

# configure fix:
EXTRA_OECMAKE += "-Dlibproxy_INCLUDE_DIR=${STAGING_INCDIR}/libproxy"
# compile fix:
OECMAKE_CXX_FLAGS += "-isystem ${STAGING_INCDIR}/glib-2.0 -isystem ${STAGING_LIBDIR}/glib-2.0/include"

do_install:append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/do-client.service ${D}${systemd_system_unitdir}

    install -m 0644 -D ${WORKDIR}/do-client.conf ${D}${libdir}/tmpfiles.d/do-client.conf
}

SYSTEMD_SERVICE:${PN} = "do-client.service"
FILES:${PN} += " \
    ${libdir}/tmpfiles.d/do-client.conf \
    ${systemd_system_unitdir}/do-client.service \
"

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM:${PN} = "-r do;-r adu"
USERADD_PARAM:${PN} = "--no-create-home -r -s /bin/false -G adu -g do do"
