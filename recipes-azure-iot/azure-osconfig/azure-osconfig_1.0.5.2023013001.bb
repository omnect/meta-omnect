FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

DESCRIPTION = "A modular services stack that facilitates remote Linux IoT \
device management over Azure"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE.md;md5=c9ff3e29b88ec39933bbd582a9efd17b"

PKGPV := "${PV}"
SRC_URI = " \
  gitsm://github.com/azure/azure-osconfig.git;protocol=https;tag=v${PKGPV};nobranch=1 \
  file://azure-iot-sdk-c-openssl3.patch;patchdir=agents/pnp/azure-iot-sdk-c/c-utility \
  file://agents_pnp_postbuild.patch;patchdir=.. \
"

PV:append = "_${SRCPV}"

# util-linux: for uuid-dev
DEPENDS = " \
  catch2 \
  curl \
  lttng-ust \
  openssl \
  rapidjson \
  util-linux \
"

# compilation fails if we add jq-native to DEPENDS so we explicitly only depend
# in do_install step
#
# TODO cmake of azure-osconfig uses DEPENDS as build var which conflicts with
# bitbake; maybe we should prevent that via patching
do_install[depends] += "jq-native:do_populate_sysroot"

RDEPENDS:${PN} = "iot-identity-service"

S = "${WORKDIR}/git/src"

inherit cmake systemd useradd

EXTRA_OECMAKE += "-DCMAKE_BUILD_TYPE=Release"
EXTRA_OECMAKE += "-Duse_prov_client=ON"
EXTRA_OECMAKE += "-Dhsm_type_symm_key=ON"
EXTRA_OECMAKE += "-DBUILD_TESTS=OFF"

do_install:append() {
  install -m 0600 -o aziotid -g aziotid -D ${D}${sysconfdir}/osconfig/osconfig.toml ${D}${sysconfdir}/aziot/identityd/config.d/osconfig.toml
  rm ${D}${sysconfdir}/osconfig/osconfig.toml
  rm ${D}${sysconfdir}/osconfig/osconfig.conn

  # disable package manager module
  jq 'del ( .Reported[] | select (."ComponentName" == "PackageManagerConfiguration"))' ${D}${sysconfdir}/osconfig/osconfig.json > tmp.json
  # explicitly reuse inode instead of using mv (prevent pseudo abort error)
  cat tmp.json > ${D}${sysconfdir}/osconfig/osconfig.json

  install -d -m 0755 ${D}${systemd_system_unitdir}
  mv ${D}${sysconfdir}/systemd/system/osconfig.service          ${D}${systemd_system_unitdir}/
  mv ${D}${sysconfdir}/systemd/system/osconfig-platform.service ${D}${systemd_system_unitdir}/
}

SYSTEMD_SERVICE:${PN} = " \
  osconfig.service \
  osconfig-platform.service \
"
FILES:${PN} += " \
  /usr/lib/osconfig \
  /lib/systemd \
"
USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM:${PN} = " \
  -r aziot; \
  -r aziotcs; \
  -r aziotid; \
  -r aziotks; \
  -r aziottpm; \
"
USERADD_PARAM:${PN} = " \
  -r -g aziotid -G aziot,aziotcs,aziotks,aziottpm -s /bin/false -d ${localstatedir}/lib/aziot/identityd aziotid; \
"
