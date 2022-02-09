DESCRIPTION = "Azure Storage Client Library for C++"
HOMEPAGE = "https://github.com/Azure/azure-sdk-for-cpp.git"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=e74f78882cab57fd1cc4c5482b9a214a"

SRC_URI = " \
    git://github.com/Azure/azure-sdk-for-cpp.git;protocol=https;tag=azure-storage-blobs_12.2.1;nobranch=1 \
    file://fix_linking_for_dependents.patch \
"

S = "${WORKDIR}/git"

DEPENDS = "curl libxml2 openssl"

EXTRA_OECMAKE += "-DCMAKE_INSTALL_DATAROOTDIR=lib/cmake"

inherit cmake

BBCLASSEXTEND = "native nativesdk"
