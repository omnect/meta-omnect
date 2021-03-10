# Build and install the azure-iot-sdk-c

DESCRIPTION = "Microsoft Azure IoT SDKs and libraries for C"
AUTHOR = "Microsoft Corporation"
HOMEPAGE = "https://github.com/Azure/azure-iot-sdk-c"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=4283671594edec4c13aeb073c219237a"

SRC_URI = "gitsm://github.com/Azure/azure-iot-sdk-c.git;tag=LTS_01_2021_Ref01;nobranch=1"

S = "${WORKDIR}/git"

# util-linux for uuid-dev
DEPENDS = "util-linux curl openssl"

inherit cmake

#provision client
EXTRA_OECMAKE += "-Duse_prov_client:BOOL=ON -Dhsm_type_sastoken:BOOL=ON -Dhsm_type_x509:BOOL=ON -Dskip_samples:BOOL=ON"

sysroot_stage_all_append () {
    sysroot_stage_dir ${D}${exec_prefix}/cmake ${SYSROOT_DESTDIR}${exec_prefix}/cmake
}

FILES_${PN}-dev += "${exec_prefix}/cmake"

BBCLASSEXTEND = "native nativesdk"
