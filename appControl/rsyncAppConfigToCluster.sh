#!/bin/bash

# See usage() for documentation.

#jq-on-msys-workaround
PATH="/d/apps/PSTools/:/mingw64/bin/:$PATH"


#------------------------------------------------------------------------------
usage()
{
    # repository directory is ONE folder above this script
    local REPO_DIRECTORY="$( readlink -f $( dirname $0 )/../ )"
    
    echo \
"Usage syntax: $0 
    <app name>
    [--dry-run]
    [-l|--local-only)]

Synchronize configuration/calibration/asset files 
${REPO_DIRECTORY}/appControl/<app name>/profiles/<activeProfile>/
to the installation directory of <app name> to each node of the cluster.

The source machine is the one this script is run on, 
target machines are all hosts listed in  ${REPO_DIRECTORY}/config/hosts.json.

You may want this functionality in order to only maintain ONE centralized
repository for config data, despite the fact that most distributed applications need those data
replicated on each node in order to run properly.

Furthermore, the 'profile' mechanism allows for easy maintenance of many different config setups.
The active profile to be synced is to be specified in 
${REPO_DIRECTORY}/config/apps.json, in the 'profile' entry belonging to 
<app name> for the currently active operating system of the cluster.

Files to ignore during sync can be specified in  
${REPO_DIRECTORY}/appControl/<appname>/sync/rsyncignore_config .

The installation directory of <app name> is parsed from the corresponding 
'installDir' entry in ${REPO_DIRECTORY}/config/apps.json.

'--dry-run' will execute a dry run, i.e. not change remote files.

'-l|--local-only' will only rsync configs on the local machine and skip remote machines.

This script builds on ${REPO_DIRECTORY}/helpers/rsyncToCluster.sh.
Hence, self-targeting (e.g. from and to a master node) is handled gracefully, either by omission or by local (non-ssh) rsyncing.

On top of this, the central cluster config usually resides in another directory as the config to be read
by the application instances. Hence even on a local machine that is not part of the cluster,
a local rsync is performed between those directories. This is useful if a remote machine (e.g. a development machine)
wants to participate as an instance of the distributed app (e.g. for a remote show where the showmaster remote controls 
e.g. a visualization dome without its machine being formally part of the cluster).

Usage examples: 
    $0 OpenSpace --dry-run
    $0 ParaView
"
}
#------------------------------------------------------------------------------



localOnly="false"



#------------------------------------------------------------------------------
rsyncAppConfigToCluster()
{
    local appName=$1
    shift
    if [[ ${appName} == "" ]]; then
        echo 
        echo "ERROR: app name argument required"
        echo
        usage
        exit 1
    fi

    local SCRIPT_DIRECTORY="$( readlink -f $( dirname $0 ))"
     # repository directory is ONE folder above this script's location
    local REPO_DIRECTORY="$( readlink -f ${SCRIPT_DIRECTORY}/.. )"

    # don't sync files with names read from the following file
    local rsyncignoreFilePath="${REPO_DIRECTORY}/appControl/${appName}/sync/rsyncignore_config"

    activeOS=$( ${REPO_DIRECTORY}/helpers/getActiveOS.sh )

    local activeProfile=$( jq ".apps.${activeOS}.${appName}.profile" ${REPO_DIRECTORY}/config/apps.json | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )
    echo "active profile: ${activeProfile}"

    echo "rsyncing to cluster: ${appName} config for active profile \"${activeProfile}\""


    local installDir_unixStyle=$( jq ".apps.${activeOS}.${appName}.installDir" ${REPO_DIRECTORY}/config/apps.json | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )


    #trailing / is important!!!11
    local sourcePath="${REPO_DIRECTORY}/appControl/${appName}/profiles/${activeProfile}/"
    

    # special treatment of dev machine: for security reasons, I don't want the dev machine to be ssh-able from the cluster, hence the common logic does not apply here:
    # special treatment of dev machine: for security reasons, I don't want the dev machine to be ssh-able from the cluster, hence the common logic does not apply here:
    if [[ $(${REPO_DIRECTORY}/helpers/thisMachineIsInHostsList.sh) == "false" ||  ${localOnly} == "true" ]]; then
        echo "Either syncing shall only occur locally, or the launching machine is not part of the cluster config."
        echo "Hence rsyncing ${appName} config locally from ${sourcePath} to ${installDir_unixStyle}:"
        sleep 1
        
		# -I
        local optionFlags="-r -z -h -v --progress"
        if [[ $1 == "--dry-run" ]]; then
            optionFlags+=" --dry-run"
        fi
        optionFlags+=" --exclude-from=${rsyncignoreFilePath}"
        
        #--include=*
        rsync $optionFlags  "${sourcePath}"  "${installDir_unixStyle}"
    fi

    if [[ ${localOnly} == "true" ]]; then
        echo "Skipping remote (cluster) rsyncing, hence exiting ..."
        exit 0
    fi

    #"${@}"
    echo "rsyncing  config and calib files to cluster: source directory : ${sourcePath} ; target directory : ${installDir_unixStyle}"
    ${REPO_DIRECTORY}/helpers/rsyncToCluster.sh  --ignorefile "${rsyncignoreFilePath}" --source-path "${sourcePath}" --target-dir "${installDir_unixStyle}" "${@}"

}
#------------------------------------------------------------------------------



#------------------------------------------------------------------------------


# parse some args
POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        -h|--help)
            usage
            exit 0
        ;;
        -l|--local-only)
            localOnly="true"
            shift
        ;;
        *)    # unknown param,  implies incorrect use here
            POSITIONAL+=("$1") # save it in an array for later
            shift # ignore
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters to this script, i.e. $@
#------------------------------------------------------------------------------


rsyncAppConfigToCluster $@

echo "sleeping 3 secs so you can see some output:"
sleep 3
