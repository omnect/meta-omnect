# check environment variables like OMNECT_TOOLS or OMNECT_DEVEL_TOOLS
# Note: it is assumed that another variable suffixed with "_DEFAULT" exists and
#       contains default settings for variable if is not currently defined
def check_for_defaultvar(d, checkvar):
    checkvarval = d.getVar(checkvar)
    if checkvarval in [None, ""]:
        # check default counterpart variable if variable is unset or empty
        dfltvarval = d.getVar(checkvar + "_DEFAULT")
        checkvarval = dfltvarval
        d.setVar(checkvar, checkvarval)

    return checkvarval

# need to use immediate set operator to prevent recursive substituion.
# also include at least one space so that variable doesn't get omitted in
# resulting os-release file
OMNECT_TOOLS := " ${@check_for_defaultvar(d, 'OMNECT_TOOLS')}"
OMNECT_DEVEL_TOOLS := " ${@oe.utils.conditional('OMNECT_RELEASE_IMAGE', '1', '', check_for_defaultvar(d, 'OMNECT_DEVEL_TOOLS'), d)}"
