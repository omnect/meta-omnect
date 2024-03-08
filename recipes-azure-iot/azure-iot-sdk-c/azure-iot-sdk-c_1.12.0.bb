DESCRIPTION = "Microsoft Azure IoT SDKs and libraries for C"
AUTHOR = "Microsoft Corporation"
HOMEPAGE = "https://github.com/Azure/azure-iot-sdk-c"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=4283671594edec4c13aeb073c219237a"

SRC_URI = "gitsm://github.com/Azure/azure-iot-sdk-c.git;branch=lts_03_2024;tag=LTS_03_2024;protocol=https"
PV .= "+${SRCPV}"
CVE_PRODUCT="microsoft:azure-iot-sdk-c"

S = "${WORKDIR}/git"

# util-linux for uuid-dev
DEPENDS = "util-linux curl openssl"

inherit cmake

EXTRA_OECMAKE += "-Duse_prov_client:BOOL=OFF"
EXTRA_OECMAKE += "-Dskip_samples:BOOL=ON"

# fix compilation of services which depend on azure-iot-sdk-c (e.g. iot-hub-device-update)
do_configure:prepend() {
   sed -i 's/${OPENSSL_LIBRARIES}/crypto ssl/g' ${S}/c-utility/CMakeLists.txt
   sed -i 's/${CURL_LIBRARIES}/curl/g' ${S}/c-utility/CMakeLists.txt
}

sysroot_stage_all:append () {
    sysroot_stage_dir ${D}${exec_prefix}/cmake ${SYSROOT_DESTDIR}${exec_prefix}/cmake
}

FILES:${PN}-dev += "${exec_prefix}/cmake"

BBCLASSEXTEND = "native nativesdk"
