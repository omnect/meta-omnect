# SPDX-License-Identifier: MIT
# Copyright 2022 BG Networks, Inc.
# Copyright 2023 conplement AG

# The product name that the CVE database uses.  Defaults to BPN, but may need to
# be overriden per recipe (for example tiff.bb sets CVE_PRODUCT=libtiff).
CVE_PRODUCT ??= "${BPN}"
CVE_VERSION ??= "${PV}"

# There are differneces in how component versions are handled by their vendors
# with respect to CPE fields 'version' and 'update'::
#  - most of them seem to put the whole version number into the version field
#  - some split the version string into pure version number and a potential
#    suffix like 'beta-1', 'rc1' or 'p1'
# In the past we used first variant for all components, but one day a sudo CVE
# hit the developemer in charge and revealed that projects appeared to be
# unaffected by it although they actually are.
# The cause lies in version number comparison between CVE's CPE entries and
# our generated SBOM for single versions: they need to fully match.
# Concrete values were ...
#  - in the CVE:
#    cpe:2.3:a:sudo_project:sudo:1.9.17:-:*:*:*:*:*:*
#    cpe:2.3:a:sudo_project:sudo:*:*:*:*:*:*:*:* (<1.9.17)
#    cpe:2.3:a:sudo_project:sudo:1.9.17:p1:*:*:*:*:*:*
#    cpe:2.3:a:sudo_project:sudo:1.9.17:p2:*:*:*:*:*:*
# in our SBOM:
#    cpe:2.3:a:*:sudo:1.9.17p1:*:*:*:*:*:*:*
# The full version in the SBOM's version field didn't match the complete
# version specification as contained in the CVE - split into version plus
# update -, so the CVE was ignored.
# From the CPE standard's point of view there is no right or wrong here, so we
# need to be prepared to deal with both situations.
# The solution is: keep SBOM generation for components as in the past unless
# an indicator - new variable OMNECT_CVE_VERSION_SPLIT, to be set component
# specific in omnect-os-cve.conf file - states otherwise ie., sets this
# variable to 1.
OMNECT_CVE_VERSION_SPLIT ??= "0"

DEPENDENCYTRACK_DIR ??= "${DEPLOY_DIR}/dependency-track"
DEPENDENCYTRACK_SBOM ??= "${DEPENDENCYTRACK_DIR}/bom.json"
DEPENDENCYTRACK_TMP ??= "${TMPDIR}/dependency-track"
DEPENDENCYTRACK_LOCK ??= "${DEPENDENCYTRACK_TMP}/bom.lock"

python do_dependencytrack_init() {
    import uuid
    from datetime import datetime

    sbom_dir = d.getVar("DEPENDENCYTRACK_DIR")
    bb.debug(2, "Creating cyclonedx directory: %s" % sbom_dir)
    bb.utils.mkdirhier(sbom_dir)

    bb.debug(2, "Creating empty sbom")
    write_sbom(d, {
        "bomFormat": "CycloneDX",
        "specVersion": "1.4",
        "serialNumber": "urn:uuid:" + str(uuid.uuid4()),
        "version": 1,
        "metadata": {
            "timestamp": datetime.now().isoformat(),
        },
        "components": []
    })
}
addhandler do_dependencytrack_init
do_dependencytrack_init[eventmask] = "bb.event.BuildStarted"

python do_dependencytrack_collect() {
    import json
    import oe.cve_check
    import re
    from pathlib import Path

    # omnect specific; we only want packages for the target in our sbom
    if d.getVar("CLASSOVERRIDE") != "class-target":
        return

    # load the bom
    name = d.getVar("CVE_PRODUCT")
    version = d.getVar("CVE_VERSION")
    split_version = d.getVar("OMNECT_CVE_VERSION_SPLIT")
    sbom = read_sbom(d)

    # update it with the new package info
    names = name.split()
    for index, cpe in enumerate(oe.cve_check.get_cpe_ids(name, version)):
        bb.debug(2, f"Collecting package {name}@{version} ({cpe})")
        cpe_split = cpe.split(":")
        if '*' == cpe_split[3]:
            purl = 'pkg:yocto/{}@{}'.format(cpe_split[4],version)
        else:
            purl = 'pkg:yocto/{}/{}@{}'.format(cpe_split[3],cpe_split[4],version)

        # recompile cpe: scarthgap sets "*" for type, kirkstone did set "a"
        cpe_split[2] = "a"
        if split_version != "0":
            # we need to use the full version from the cpe string because it
            # is already cleaned from any '+git' suffix
            full_ver = cpe_split[5]
            m = re.search('^([0-9]+(?:[.][0-9]+)*)([-+_a-zA-Z]+.*)?$', full_ver)
            bb.debug(1, "component[split]: {} / {} ({}) - m: {}".format(name, full_ver, version, m))
            bb.debug(1, "component[split]: cpe {}". format(cpe))
            if len(m.groups()) > 1:
                bb.debug(1, "component[split]: version slpit {} / {}". format(m[1], m[2]))
            else:
                bb.debug(1, "component[split]: version slpit {} / -". format(m[1]))
            cpe_split[5] = m[1]
            if len(m.groups()) > 2:
                cpe_split[6] = m[2]
            else:
                cpe_split[6] = '-'
        else:
            # version has already the correct content, just ensure that update
            # field is correct here
            cpe_split[6] = '*'
            
        cpe = ":".join(cpe_split)
        bb.debug(1, "component: resulting cpe {}". format(cpe))

        if not next((c for c in sbom["components"] if c["cpe"] == cpe), None):
            sbom["components"].append({
                "name": names[index],
                "version": version,
                "cpe": cpe,
                "purl": purl,
                "type": "application"
            })

    # write it back to the deploy directory
    write_sbom(d, sbom)
}

addtask dependencytrack_collect before do_build after do_fetch
do_dependencytrack_collect[nostamp] = "1"
do_dependencytrack_collect[lockfiles] += "${DEPENDENCYTRACK_LOCK}"
do_rootfs[recrdeptask] += "do_dependencytrack_collect"

def read_sbom(d):
    import json
    from pathlib import Path
    return json.loads(Path(d.getVar("DEPENDENCYTRACK_SBOM")).read_text())

def write_sbom(d, sbom):
    import json
    from pathlib import Path
    Path(d.getVar("DEPENDENCYTRACK_SBOM")).write_text(
        json.dumps(sbom, indent=2)
    )
