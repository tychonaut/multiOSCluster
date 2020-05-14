#!/bin/bash

# This script synchronizes the contents of a given app installation directory 
# to all the cluster machines specified in {REPO_DIRECTORY}/config/hosts.json .
# Files to ignore during sync can be specified in  ${REPO_DIRECTORY}/appControl/<appname>/sync/rsyncignore_install .
# If the running machine is itself part of the cluster (including being a master), self-sending is omitted.
# Self-targeting of machines will be omitted.
#
# Usage example: $0 OpenSpace

#jq-on-msys-workaround
PATH="/d/apps/PSTools/:/mingw64/bin/:$PATH"

rsyncAppInstallDirToCluster()
{
    local appName=$1
    shift

    local SCRIPT_DIRECTORY=$( readlink -f $( dirname $0 ))
    # repository directory is ONE folder above this script
    echo "TODO adapt REPO_DIRECTORY after moving"
    local REPO_DIRECTORY="$( readlink -f $( dirname $0 )/../ )"


    # don't sync files with names read from the following file
    local rsyncignoreFilePath="${REPO_DIRECTORY}/appControl/${appName}/sync/rsyncignore_install"


    local appInstallDirectory=$( jq '.apps.Windows.${appName}.installDir' ${REPO_DIRECTORY}/config/apps.json | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )

    ## target dir must omit the last folder name
    local targetDir="$( readlink -f ${appInstallDirectory}/.. )"

    echo "${appName} installation directory: rsync SOURCE directory: ${appInstallDirectory}"
    echo "${appName} installation directory: rsync TARGET directory: ${targetDir}"
    sleep 2

    # recursive, compress during transfer, human readable, verbose, show progress, -e: specify remote shell (ssh)    
    ${REPO_DIRECTORY}/helpers/rsyncToCluster.sh --ignorefile "${rsyncignoreFilePath}" --source-path "${appInstallDirectory}" --target-dir "${targetDir}" $@
    
}

rsyncAppInstallationToCluster $@