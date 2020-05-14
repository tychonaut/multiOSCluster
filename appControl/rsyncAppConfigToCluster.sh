#!/bin/bash

# This script synchronizes the contents of a given app installation directory 
# to all the cluster machines specified in {REPO_DIRECTORY}/config/hosts.json .
# Files to ignore during sync can be specified in  ${REPO_DIRECTORY}/appControl/<appname>/sync/rsyncignore_install .
# If the running machine is itself part of the cluster (including being a master), self-sending is omitted.
# Self-targeting of machines will be omitted.
#
# Usage example: $0 OpenSpace [--dry-run] 

#jq-on-msys-workaround
PATH="/d/apps/PSTools/:/mingw64/bin/:$PATH"

rsyncAppConfigToCluster()
{
    local appName=$1
    shift

    local SCRIPT_DIRECTORY="$( readlink -f $( dirname $0 ))"
     # repository directory is ONE folder above this script's location
    local REPO_DIRECTORY="$( readlink -f ${SCRIPT_DIRECTORY}/.. )"

    # don't sync files with names read from the following file
    local rsyncignoreFilePath="${REPO_DIRECTORY}/appControl/${appName}/sync/rsyncignore_config"


    local activeProfile=$( jq '.apps.Windows.${appName}.profile' ${REPO_DIRECTORY}/config/apps.json | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )
    echo "active profile: ${activeProfile}"

    echo "rsyncing to cluster: ${appName} config for active profile \"${activeProfile}\""


    local installDir_unixStyle=$( jq '.apps.Windows.${appName}.installDir' ${REPO_DIRECTORY}/config/apps.json | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )


    #trailing / is important!!!11
    local sourcePath="${REPO_DIRECTORY}/appControl/${appName}/profiles/${activeProfile}/"

    # special treatment of dev machine: for security reasons, I don't want the dev machine to be ssh-able from the cluster, hence the common logic does not apply here:
    # special treatment of dev machine: for security reasons, I don't want the dev machine to be ssh-able from the cluster, hence the common logic does not apply here:
    if [[ $(${REPO_DIRECTORY}/helpers/thisMachineIsInHostsList.sh) == "false" ]]; then
        echo "The launching machine is not part of the cluster config. Inferring that this is a remote development machine:"
        echo "Hence rsyncing ${appName} config locally from ${sourcePath} to ${installDir_unixStyle}:"
        
		# -I
        local optionFlags="-r -z -h -v --progress"
        if [[ $1 == "--dry-run" ]]; then
            optionFlags+=" --dry-run"
        fi
        optionFlags+=" --exclude-from=${rsyncignoreFilePath}"
        
        #--include=*
        rsync $optionFlags  "${sourcePath}"  "${installDir_unixStyle}"
    fi

    #"${@}"
    echo "rsyncing  config and calib files to cluster: source directory : ${sourcePath} ; target directory : ${installDir_unixStyle}"
    ${REPO_DIRECTORY}/helpers/rsyncToCluster.sh  --ignorefile "${rsyncignoreFilePath}" --source-path "${sourcePath}" --target-dir "${installDir_unixStyle}" "${@}"

}

rsyncAppConfigToCluster $@

echo "sleeping 3 secs so you can see some output:"
sleep 3
