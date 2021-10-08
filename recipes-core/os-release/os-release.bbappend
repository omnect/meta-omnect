inherit metadata_scm

OS_RELEASE_FIELDS += "META_ICS_DM_SHA"
META_ICS_DM_SHA = "${@base_get_metadata_git_revision('${LAYERDIR_ics_dm}', d)}"

OS_RELEASE_FIELDS += "ICS_DM_OS_SHA ICS_DM_OS_BRANCH"
ICS_DM_OS_SHA = "${GitVersion_Sha}"
ICS_DM_OS_BRANCH = "${GitVersion_BranchName}"

OS_RELEASE_FIELDS += "DISTRO_FEATURES"

do_compile[nostamp] = "1"
