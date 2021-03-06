#!/bin/bash 

#jq-on-mys-workaround
PATH="/d/apps/PSTools:/mingw64/bin/:$PATH"


launchOpenSpaceOnCluster()
{

    local SCRIPT_DIRECTORY="$( readlink -f $( dirname $0 ))"
     # repository directory is four folders above this script's location
    local REPO_DIRECTORY="$( readlink -f ${SCRIPT_DIRECTORY}/../../../.. )"

    echo "launching OpenSpace on cluster ...."


    local activeProfile=$( jq '.apps.Windows.OpenSpace.profile' ${REPO_DIRECTORY}/config/apps.json | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )
    echo "active profile: ${activeProfile}"


    local installDir_unixStyle=$( jq '.apps.Windows.OpenSpace.installDir' ${REPO_DIRECTORY}/config/apps.json | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )
    local installDir_windowsStyle=$( cygpath.exe -a -w -m "${installDir_unixStyle}" )

    local exe_unixStyle=$( jq '.apps.Windows.OpenSpace.executable' ${REPO_DIRECTORY}/config/apps.json | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )
    local exe_windowsStyle=$( cygpath.exe -w -m "${exe_unixStyle}" )


    echo "installation directory: ${installDir_windowsStyle}"
    echo "executable: ${exe_windowsStyle}"




    # special treatment of dev machine: for security reasons, I don't want the dev machine to be ssh-able from the cluster, hence the common logic does not apply here:
    if [[ $(${REPO_DIRECTORY}/helpers/thisMachineIsInHostsList.sh) == "false" ]]; then
        echo "The launching machine is not part of the cluster config. Inferring that this is a remote development machine:"
        echo "Hence launching OpenSpace locally, but also via PsExec64:"
        ## argh those trailing slashes...
        /D/apps/PSTools/PsExec64.exe -i -d  ${installDir_windowsStyle}/${exe_windowsStyle}
        
        #-d \\\\$(hostname) -h -s
    fi




    
    #parse OS credentials:
    # this construct requires the whole script repo to reside on each computer, and in the same directory!
    local hostCredPath="${REPO_DIRECTORY}/helpers/getHostCreds.sh"


    ##wftz: on master, it needs another flag than on the rest...?" 
    ## YES, for whatever f***ed-up reasons! THE FOLLOWING WORKS! (for now, untilk next reboot/rename, whatever ...)
    ## so differentiate:
    #${REPO_DIRECTORY}/manage/performOnClusterNodes.sh --masters -NAS --execute-command "/D/apps/PSTools/PsExec64.exe -i -d \\\\\\\\\$(hostname) -h -s  ${installDir_windowsStyle}/${exe_windowsStyle}"
    #${REPO_DIRECTORY}/manage/performOnClusterNodes.sh --slaves -NAS --execute-command "/D/apps/PSTools/PsExec64.exe -i -d \\\\\\\\\$(hostname) -h -u \$(${hostCredPath} username) -p \$(${hostCredPath} pw) ${installDir_windowsStyle}/${exe_windowsStyle}"
    
    
    # now it stoppped working on master without any noticable change from one run to another, i.e. within seconds! 
    # no reboot, change of scripts, change in OS whatsoever!
    ${REPO_DIRECTORY}/manage/performOnClusterNodes.sh --all -NAS --execute-command "/D/apps/PSTools/PsExec64.exe -i -d \\\\\\\\\$(hostname) -h -u \$(${hostCredPath} username) -p \$(${hostCredPath} pw) ${installDir_windowsStyle}/${exe_windowsStyle}"
	
	
	##after windows update from 2020/07/23 that reset all graphics settings, the old "which permutation works on which machine, and only after som other permutations have been 
	## tried for the same machine"-issue was back. The following sepeation for master and slaves seems to work now:
	#${REPO_DIRECTORY}/manage/performOnClusterNodes.sh -m -NAS --execute-command "/D/apps/PSTools/PsExec64.exe -i -d \\\\\\\\\$(hostname) -h -u \$(${hostCredPath} username) -p \$(${hostCredPath} pw) ${installDir_windowsStyle}/${exe_windowsStyle}"
	#${REPO_DIRECTORY}/manage/performOnClusterNodes.sh -s -NAS --execute-command "/D/apps/PSTools/PsExec64.exe -i -d \\\\\\\\\$(hostname) -h -s ${installDir_windowsStyle}/${exe_windowsStyle}"


    echo "done launching Openspace on cluster ..."
    sleep 3

}


launchOpenSpaceOnCluster
