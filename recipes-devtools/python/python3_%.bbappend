python() {
    from pathlib import Path

    # we may have no workdir at parsetime -> create directly in DEPLOY_DIR_IMAGE
    Path(d.getVar("DEPLOY_DIR_IMAGE")).mkdir(parents=True, exist_ok=True)

    packages = d.getVar('PACKAGES')
    packages_file_out = Path(d.getVar("DEPLOY_DIR_IMAGE") + "/python_packages.txt").open('w')
    packages_file_out.write("%s\n" % packages)
}