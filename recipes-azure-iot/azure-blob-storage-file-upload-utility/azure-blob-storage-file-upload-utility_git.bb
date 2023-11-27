DESCRIPTION = "This project is a wrapper utility for the Azure SDK for Cpp's Storage SDK for use in DeviceUpdate in IotHub."
HOMEPAGE = "https://github.com/Azure/azure-blob-storage-file-upload-utility"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=d4a904ca135bb7bc912156fee12726f0"

SRC_URI = "git://github.com/Azure/azure-blob-storage-file-upload-utility.git;protocol=https;nobranch=1;rev=8fff8d830aa07e218186e27ad21af018280801ec"

PV .= "+${SRCPV}"

S = "${WORKDIR}/git"

DEPENDS = " \
  azure-iot-sdk-c \
  azure-sdk-for-cpp \
  curl \
"

inherit cmake

BBCLASSEXTEND = "native nativesdk"
