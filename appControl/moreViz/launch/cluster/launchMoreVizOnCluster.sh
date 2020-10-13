#!/bin/bash 

#jq-on-mys-workaround
PATH="/d/apps/PSTools:/mingw64/bin/:$PATH"


launchMoreVizOnCluster()
{

    local SCRIPT_DIRECTORY="$( readlink -f $( dirname $0 ))"
     # repository directory is four folders above this script's location
    local REPO_DIRECTORY="$( readlink -f ${SCRIPT_DIRECTORY}/../../../.. )"

    echo "launching moreViz on cluster ...."


    local activeProfile=$( jq '.apps.Windows.moreViz.profile' ${REPO_DIRECTORY}/config/apps.json | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )
    echo "active profile: ${activeProfile}"

    local installDir_unixStyle=$( jq '.apps.Windows.moreViz.installDir' ${REPO_DIRECTORY}/config/apps.json | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )
    local installDir_windowsStyle=$( cygpath.exe -a -w -m "${installDir_unixStyle}" )

    local exe_unixStyle=$( jq '.apps.Windows.moreViz.executable' ${REPO_DIRECTORY}/config/apps.json | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )
    local exe_windowsStyle=$( cygpath.exe -w -m "${exe_unixStyle}" )

    echo "installation directory: ${installDir_windowsStyle}"
    echo "executable: ${exe_windowsStyle}"


    
    #parse OS credentials:
    # this construct requires the whole script repo to reside on each computer, and in the same directory!
    local hostCredPath="${REPO_DIRECTORY}/helpers/getHostCreds.sh"


    ${REPO_DIRECTORY}/manage/performOnClusterNodes.sh --slaves -NAS --execute-command "/D/apps/PSTools/PsExec64.exe -i -d \\\\\\\\\$(hostname) -h -u \$(${hostCredPath} username) -p \$(${hostCredPath} pw) \"${installDir_windowsStyle}/${exe_windowsStyle}\""
		
    echo "done launching moreViz on cluster ..."
    sleep 3

}


launchMoreVizOnCluster
