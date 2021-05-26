python () {
    repo_uri = d.getVar(str.upper(d.getVar('PN')).replace('-','_') + '_SRC_URI')
    if repo_uri:
      d.setVar('REPO_URI', repo_uri)
}
