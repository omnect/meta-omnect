# SPDX-License-Identifier: MIT
# Copyright 2022 BG Networks, Inc.
# Copyright 2023 conplement AG

# The product name that the CVE database uses.  Defaults to BPN, but may need to
# be overriden per recipe (for example tiff.bb sets CVE_PRODUCT=libtiff).
CVE_PRODUCT ??= "${BPN}"
CVE_VERSION ??= "${PV}"

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
    from pathlib import Path

    # omnect specific; we only want packages for the target in our sbom
    if d.getVar("CLASSOVERRIDE") != "class-target":
        return

    # load the bom
    name = d.getVar("CVE_PRODUCT")
    version = d.getVar("CVE_VERSION")
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
        if not next((c for c in sbom["components"] if c["cpe"] == cpe), None):
            sbom["components"].append({
                "name": names[index],
                "version": version,
                "cpe": cpe,
                "purl": purl,
                "type": "library"
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
