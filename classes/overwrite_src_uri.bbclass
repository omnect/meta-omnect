python () {
    src_uri = d.getVar(str.upper(d.getVar('PN')) + '_SRC_URI')
    src_uri.replace('-', '_')
    if src_uri:
      d.setVar('SRC_URI', src_uri)
}