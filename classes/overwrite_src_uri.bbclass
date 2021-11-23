python () {
    import collections
    repo_uri = d.getVar(str.upper(d.getVar('PN')).replace('-','_') + '_SRC_URI')
    p = collections.OrderedDict()
    if repo_uri:
      d.setVar('REPO_URI', repo_uri)
      for param in repo_uri.split(';'):
        if param:
          if '=' in param:
            s1, s2 = param.split('=')
            p[s1] = s2
      if not p.get('rev'):
        d.setVar('SRCREV', "AUTOINC")
}
