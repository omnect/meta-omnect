FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:${LAYERDIR_ics_dm}/files/azure-iot-sdk-c-patches:"

DESCRIPTION = "A modular services stack that facilitates remote Linux IoT \
device management over Azure"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE.md;md5=c9ff3e29b88ec39933bbd582a9efd17b"

PKGPV := "${PV}"
SRC_URI = " \
  gitsm://github.com/azure/azure-osconfig.git;protocol=https;tag=v${PKGPV};nobranch=1 \
  file://0001-adapt-for-openssl-3.0.3.patch;patchdir=agents/pnp/azure-iot-sdk-c \
"

PV:append = "_${SRCPV}"

# util-linux: for uuid-dev
# gmock: we build with tests off, but fail to compile when we leave it out
DEPENDS = " \
  catch2 \
  curl \
  gmock \
  lttng-ust \
  openssl \
  rapidjson \
  util-linux \
"

RDEPENDS:${PN} = "iot-identity-service"

S = "${WORKDIR}/git/src"

inherit cmake

EXTRA_OECMAKE += "-DCMAKE_BUILD_TYPE=Release"
EXTRA_OECMAKE += "-Duse_prov_client=ON"
EXTRA_OECMAKE += "-Dhsm_type_symm_key=ON"
EXTRA_OECMAKE += "-DBUILD_TESTS=OFF"



FILES:${PN} += "/usr/lib/osconfig"
