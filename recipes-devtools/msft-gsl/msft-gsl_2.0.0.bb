# Build and install the Microsoft GSL library

DESCRIPTION = "Microsoft Guidelines Support Library (GSL)"
AUTHOR = "Microsoft Corporation"
HOMEPAGE = "https://github.com/microsoft/GSL"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=363055e71e77071107ba2bb9a54bd9a7"

SRC_URI = "gitsm://github.com/microsoft/GSL.git;protocol=https;branch=main;rev=1995e86d1ad70519465374fb4876c6ef7c9f8c61"

PV .= "+${SRCPV}"

S = "${WORKDIR}/git"

inherit cmake

EXTRA_OECMAKE += "-DGSL_TEST=OFF"
