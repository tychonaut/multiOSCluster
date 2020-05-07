#!/bin/bash 


#jq-on-mys-workaround
PATH="/d/apps/PSTools:/mingw64/bin/:$PATH"

#usage: rsyncConfigForSelectedProfileToCluster.sh [--dry-run] 
rsyncConfigForSelectedProfileToCluster()
{
    local SCRIPT_DIRECTORY="$( readlink -f $( dirname $0 ))"
     # repository directory is three folders above this script's location
    local REPO_DIRECTORY="$( readlink -f ${SCRIPT_DIRECTORY}/../../.. )"


    local activeProfile=$( jq '.apps.Windows.OpenSpace.profile' ${REPO_DIRECTORY}/config/apps.json | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )
    echo "active profile: ${activeProfile}"

    echo "rsyncing to cluster: OpenSpace config for active profile \"${activeProfile}\""


    local installDir_unixStyle=$( jq '.apps.Windows.OpenSpace.installDir' ${REPO_DIRECTORY}/config/apps.json | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )


    #trailing / is important!!!11
    local sourcePath="${REPO_DIRECTORY}/appControl/OpenSpace/profiles/${activeProfile}/"

    # special treatment of dev machine: for security reasons, I don't want the dev machine to be ssh-able from the cluster, hence the common logic does not apply here:
    # special treatment of dev machine: for security reasons, I don't want the dev machine to be ssh-able from the cluster, hence the common logic does not apply here:
    if [[ $(${REPO_DIRECTORY}/helpers/thisMachineIsInHostsList.sh) == "false" ]]; then
        echo "The launching machine is not part of the cluster config. Inferring that this is a remote development machine:"
        echo "Hence rsyncing OpenSpace config locally from ${sourcePath} to ${installDir_unixStyle}:"
        
        local optionFlags="-r -z -h -v --progress -I"
        if [[ $1 == "--dry-run" ]]; then
            optionFlags+=" --dry-run"
        fi
        
        #--include=*
        rsync $optionFlags  "${sourcePath}"  "${installDir_unixStyle}"
    fi

    #"${@}"
    echo "rsyncing  config and calib files to cluster: source directory : ${sourcePath} ; target directory : ${installDir_unixStyle}"
    ${REPO_DIRECTORY}/helpers/rsyncToCluster.sh  --source-path "${sourcePath}" --target-dir "${installDir_unixStyle}" "${@}"

}

rsyncConfigForSelectedProfileToCluster $@

