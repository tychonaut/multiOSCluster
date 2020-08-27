#!/bin/bash 

# jq-on-msys2-workaround
PATH="/d/apps/PSTools:/mingw64/bin/:$PATH"


launchCosmoScoutVROnCluster()
{

    local SCRIPT_DIRECTORY="$( readlink -f $( dirname $0 ))"
     # repository directory is four folders above this script's location
    local REPO_DIRECTORY="$( readlink -f ${SCRIPT_DIRECTORY}/../../../.. )"

    echo "launching CosmoScoutVR on cluster (MS Windows) ...."


    local activeProfile=$( jq '.apps.Windows.CosmoScoutVR.profile' ${REPO_DIRECTORY}/config/apps.json | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )
    echo "active profile: ${activeProfile}"


    local installDir_unixStyle=$( jq '.apps.Windows.CosmoScoutVR.installDir' ${REPO_DIRECTORY}/config/apps.json | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )
    local installDir_windowsStyle=$( cygpath.exe -a -w -m "${installDir_unixStyle}" )

    local exe_unixStyle=$( jq '.apps.Windows.CosmoScoutVR.executable' ${REPO_DIRECTORY}/config/apps.json | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )
    local exe_windowsStyle=$( cygpath.exe -w -m "${exe_unixStyle}" )


    echo "installation directory: ${installDir_windowsStyle}"
    echo "executable: ${exe_windowsStyle}"



    # special treatment of dev machine: for security reasons, I don't want the dev machine to be ssh-able from the cluster, hence the common logic does not apply here:
    if [[ $(${REPO_DIRECTORY}/helpers/thisMachineIsInHostsList.sh) == "false" ]]; then
        echo "The launching machine is not part of the cluster config. Inferring that this is a remote development machine:"
        echo "Hence launching CosmoScoutVR locally, but also via PsExec64:"
        ## argh those trailing slashes...
        /D/apps/PSTools/PsExec64.exe -i -d  ${installDir_windowsStyle}/${exe_windowsStyle}       
    fi

    
    #parse OS credentials:
    # this construct requires the whole script repo to reside on each computer, and in the same directory!
    local hostCredPath="${REPO_DIRECTORY}/helpers/getHostCreds.sh"

    #[-m|--master|--masters]  [-s|--slaves] ] 

    ${REPO_DIRECTORY}/manage/performOnClusterNodes.sh --all -NAS --execute-command "/D/apps/PSTools/PsExec64.exe -i -d \\\\\\\\\$(hostname) -h -u \$(${hostCredPath} username) -p \$(${hostCredPath} pw) ${installDir_windowsStyle}/${exe_windowsStyle}"
	
	
    echo "done launching CosmoScoutVR on cluster ..."
    sleep 3

}


launchCosmoScoutVROnCluster
