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


usage()
{
    # repository directory is ONE folder above this script
    local REPO_DIRECTORY="$( readlink -f $( dirname $0 )/../ )"
    
    echo \
"Usage syntax: $0 
    <app name>
    [--dry-run]

Synchronize the installation directory of <app name> in the cluster, the source being the machine this
script is run on, targets being all hosts listed in  ${REPO_DIRECTORY}/config/hosts.json.

You will want this to quickly reflect programming changes to the cluster after having performed local compilation,
tests and local install (e.g. via 'ninja install').

'--dry-run' will execute a dry run, i.e. not change remote files.

The installation directory of <app name> is parsed from the corresponding 
'installDir' entry in ${REPO_DIRECTORY}/config/apps.json.
Target directories on the cluster nodes will be equal to the source's app install directory.

This script builds on ${REPO_DIRECTORY}/helpers/rsyncToCluster.sh.
Hence, self-targeting (e.g. from and to a master node) is handled gracefully, either by omission or by local (non-ssh) rsyncing.
"
}



rsyncAppInstallDirToCluster()
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

    local SCRIPT_DIRECTORY=$( readlink -f $( dirname $0 ))
    # repository directory is ONE folder above this script
    local REPO_DIRECTORY="$( readlink -f $( dirname $0 )/../ )"


    # don't sync files with names read from the following file
    local rsyncignoreFilePath="${REPO_DIRECTORY}/appControl/${appName}/sync/rsyncignore_install"

    

    local appInstallDirectory=$( jq ".apps.Windows.${appName}.installDir" ${REPO_DIRECTORY}/config/apps.json | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )
    

    
    if [[ ${appInstallDirectory} == "" ]]; then
        echo
        echo "ERROR: app install dir not found"
        echo
        usage
        exit 1
    fi
    

    ## target dir must omit the last folder name
    local targetDir="$( readlink -f ${appInstallDirectory}/.. )"
    
    #echo "${appInstallDirectory}"
    #echo "${targetDir}"
    #exit 1

    echo "${appName} installation directory: rsync SOURCE directory: ${appInstallDirectory}"
    echo "${appName} installation directory: rsync TARGET directory: ${targetDir}"
    sleep 2

    # recursive, compress during transfer, human readable, verbose, show progress, -e: specify remote shell (ssh)    
    ${REPO_DIRECTORY}/helpers/rsyncToCluster.sh --ignorefile "${rsyncignoreFilePath}" --source-path "${appInstallDirectory}" --target-dir "${targetDir}" $@
    
}


POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        -h|--help)
            usage
            exit 0
        ;;
        *)    # unknown param,  implies incorrect use here
            POSITIONAL+=("$1") # save it in an array for later
            shift # ignore
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters to this script, i.e. $@

rsyncAppInstallDirToCluster $@