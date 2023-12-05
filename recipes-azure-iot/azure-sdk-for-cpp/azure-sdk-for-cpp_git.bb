DESCRIPTION = "Azure Storage Client Library for C++"
HOMEPAGE = "https://github.com/Azure/azure-sdk-for-cpp.git"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=e74f78882cab57fd1cc4c5482b9a214a"

AZURE_SDK_FOR_CPP_VERSION="azure-storage-blobs_12.2.1"
SRC_URI = "git://github.com/Azure/azure-sdk-for-cpp.git;protocol=https;tag=${AZURE_SDK_FOR_CPP_VERSION};branch=main \
           file://fix_linking_for_dependents.patch \
           file://workaround-deprecated-declarations-openssl3.patch \
           "
PV = "${AZURE_SDK_FOR_CPP_VERSION}+${SRCPV}"

S = "${WORKDIR}/git"

DEPENDS = "curl libxml2 openssl"

EXTRA_OECMAKE += "-DCMAKE_INSTALL_DATAROOTDIR=lib/cmake"

inherit cmake

EXTRA_OECMAKE += "-DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=true"

BBCLASSEXTEND = "native nativesdk"
