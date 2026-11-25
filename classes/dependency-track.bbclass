# SPDX-License-Identifier: MIT
# Copyright 2022 BG Networks, Inc.
# Copyright 2023 conplement AG

# The product name that the CVE database uses.  Defaults to BPN, but may need to
# be overriden per recipe (for example tiff.bb sets CVE_PRODUCT=libtiff).
CVE_PRODUCT ??= "${BPN}"
CVE_VERSION ??= "${PV}"

# There are differences in how component versions are handled by their vendors
# with respect to CPE fields 'version' and 'update':
#  - most of them seem to put the whole version number into the version field
#  - some split the version string into pure version number and a potential
#    suffix like 'beta-1', 'rc1' or 'p1'
# In the past we used first variant for all components, but one day a sudo CVE
# hit the developer in charge and revealed that projects appeared to be
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
DEPENDENCYTRACK_FACTS_TMP ??= "${DEPENDENCYTRACK_TMP}/build-facts"
DEPENDENCYTRACK_FACTS ??= "${DEPENDENCYTRACK_DIR}/build-facts.${PN}.json"
DEPENDENCYTRACK_FACTS_MERGE ??= ""

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
            if m == None:
                bb.fatal("component {}: version {} cannot be split".format(name, full_ver))

            bb.debug(1, "component[split]: {} / {} ({}) - m: {}".format(name, full_ver, version, m))
            bb.debug(1, "component[split]: cpe {}". format(cpe))
            cpe_split[5] = m[1]
            if m.groups()[1] != None:
                cpe_split[6] = m[2]
            else:
                cpe_split[6] = '-'
            bb.debug(1, "component[split]: version split {} / {}".format(cpe_split[5], cpe_split[6]))
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

    write_recipe_facts(d)
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

# Build facts: see doc/build_facts.md

def write_recipe_facts(d):
    import json
    import os
    import oe.patch

    path = os.path.join(d.getVar("DEPENDENCYTRACK_FACTS_TMP"), d.getVar("PN") + ".json")
    if bb.data.inherits_class("image", d):
        # an image is not a component of itself; drop a fragment from an older build
        bb.utils.remove(path)
        return

    paths = {
        "<WORKDIR>": d.getVar("WORKDIR"),
        "<TMPDIR>": d.getVar("TMPDIR"),
        "<TOPDIR>": d.getVar("TOPDIR"),
        "<COREBASE>": d.getVar("COREBASE"),
        "<DL_DIR>": d.getVar("DL_DIR"),
    }

    def clean(value):
        value = omnect.build_facts.replace_paths(value or "", paths)
        return omnect.build_facts.normalize_ws(omnect.build_facts.mask_jobs(value))

    configure_args = {}
    for cls, var in omnect.build_facts.CONFIGURE_ARGS_BY_CLASS:
        if bb.data.inherits_class(cls, d):
            configure_args[var] = clean(d.getVar(var))
    for var in ("EXTRA_OEMAKE", "CARGO_FEATURES"):
        if (d.getVar(var) or "").strip():
            configure_args[var] = clean(d.getVar(var))

    kconfig = {}
    if bb.data.inherits_class("kernel", d):
        kconfig["KBUILD_DEFCONFIG"] = clean(d.getVar("KBUILD_DEFCONFIG"))
        # the order of the features is the order of the config fragments
        kconfig["KERNEL_FEATURES"] = (d.getVar("KERNEL_FEATURES") or "").split()

    fetch = bb.fetch2.Fetch([], d)
    patches = set()
    for patch in oe.patch.src_patches(d, expand=False):
        patches.add(bb.fetch2.decodeurl(patch)[2])

    # SRC_URI order: patches and config fragments are applied in this order
    srcrev = {}
    src_files = []
    remote_files = []
    for url in fetch.urls:
        ud = fetch.ud[url]
        address = url.split(";")[0]
        if ud.type in ("git", "gitsm"):
            # the resolved commit, also for ;rev=, ;tag= and AUTOREV
            srcrev[ud.parm["name"] if "name" in ud.parm else address] = ud.revision
        elif ud.type == "file":
            local = fetch.localpath(url)
            src_files.append({
                "name": address[len("file://"):],
                "sha256": omnect.build_facts.sha256_path(local),
                "patch": local in patches,
            })
        else:
            remote_files.append({
                "url": clean(address),
                "sha256": getattr(ud, "sha256_expected", None),
                "patch": fetch.localpath(url) in patches,
            })

    facts = {
        "version": d.getVar("PV"),
        "srcrev": dict(sorted(srcrev.items())),
        "cve_products": (d.getVar("CVE_PRODUCT") or "").split(),
        "packageconfig": omnect.build_facts.sorted_words(d.getVar("PACKAGECONFIG")),
        "configure_args": configure_args,
        "kconfig": kconfig,
        "src_files": src_files,
        "remote_files": remote_files,
        "provides": (d.getVar("PROVIDES") or "").split(),
        "depends": bb.utils.explode_deps(d.getVar("DEPENDS") or ""),
    }

    bb.utils.mkdirhier(os.path.dirname(path))
    with open(path, "w") as f:
        json.dump(facts, f, indent=2, sort_keys=True)

python dependencytrack_write_facts() {
    import json
    import os
    import oe.package
    import oe.rootfs

    # Only the recipes of this image: the fragment directory also holds
    # recipes of other images and of earlier builds.
    taskdepdata = d.getVar("BB_TASKDEPDATA", False)
    pns = sorted({t[0] for t in taskdepdata.values() if t[1] == "do_dependencytrack_collect"})

    facts_dir = d.getVar("DEPENDENCYTRACK_FACTS_TMP")
    recipes = {}
    for pn in pns:
        path = os.path.join(facts_dir, pn + ".json")
        # no fragment for recipes that are not built for the target
        if os.path.exists(path):
            with open(path) as f:
                recipes[pn] = json.load(f)

    pkgdata_dir = d.getVar("PKGDATA_DIR")
    deploy_ipk = d.getVar("DEPLOY_DIR_IPK")
    packages = {}
    files = {}
    for pkg, info in sorted(oe.rootfs.image_list_installed_packages(d).items()):
        with open(os.path.join(pkgdata_dir, "runtime-reverse", pkg)) as f:
            pkgdata = omnect.build_facts.parse_pkgdata(f.read())
        pn = pkgdata.get("PN")
        ipk = os.path.join(deploy_ipk, info["arch"], omnect.build_facts.ipk_filename(pkg, info["ver"], info["arch"]))
        if not os.path.exists(ipk):
            bb.fatal("build facts: %s not found" % ipk)
        packages.setdefault(pn, {})[pkg] = omnect.build_facts.ipk_sha256(ipk)
        provides, depends = omnect.build_facts.per_file_deps(pkgdata)
        file_provides, file_depends = files.setdefault(pn, ({}, {}))
        file_provides.update({oe.package.file_reverse_translate(f): v for f, v in provides.items()})
        file_depends.update({oe.package.file_reverse_translate(f): v for f, v in depends.items()})

    linked_by = omnect.build_facts.linked_by(files)
    built_into = omnect.build_facts.built_into(recipes)

    out = {}
    for pn, r in recipes.items():
        r.pop("provides")
        r.pop("depends")
        r["installed_packages"] = packages.get(pn, {})
        r["linked_by"] = linked_by.get(pn, {})
        r["built_into"] = built_into[pn]
        out[pn] = r

    facts = {
        "format_version": omnect.build_facts.FORMAT_VERSION,
        "machine": d.getVar("MACHINE"),
        "distro_version": d.getVar("DISTRO_VERSION"),
        "recipes": out,
        "image": {
            "image_features": omnect.build_facts.sorted_words(d.getVar("IMAGE_FEATURES")),
            "enabled_units": omnect.build_facts.enabled_units(
                os.path.join(d.getVar("IMAGE_ROOTFS"), d.getVar("sysconfdir").lstrip("/"), "systemd", "system")),
        },
    }

    for image in (d.getVar("DEPENDENCYTRACK_FACTS_MERGE") or "").split():
        path = d.getVar("DEPENDENCYTRACK_FACTS").replace("build-facts.%s." % d.getVar("PN"), "build-facts.%s." % image)
        if not os.path.exists(path):
            bb.fatal("build facts: %s not found, run do_image of %s again" % (path, image))
        with open(path) as f:
            other = json.load(f)
        try:
            omnect.build_facts.check_merge(facts, other, path)
        except ValueError as e:
            bb.fatal("build facts: %s" % e)
        omnect.build_facts.merge_recipes(out, other["recipes"])

    path = d.getVar("DEPENDENCYTRACK_FACTS")
    bb.utils.mkdirhier(os.path.dirname(path))
    with open(path, "w") as f:
        json.dump(facts, f, indent=2, sort_keys=True)
}
dependencytrack_write_facts[vardepsexclude] += "BB_TASKDEPDATA"

# after IMAGE_PREPROCESS_COMMAND, which can still change the rootfs
do_image[postfuncs] += "dependencytrack_write_facts"
do_image[depends] += "${@' '.join('%s:do_image' % i for i in d.getVar('DEPENDENCYTRACK_FACTS_MERGE').split())}"
