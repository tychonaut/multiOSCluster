#!/bin/bash

# This script copies the whole contents of the multiOSCluster repository 
# to all the cluster machines specified in {REPO_DIRECTORY}/config/hosts.json including masters
# (without git meta files, which are excluded via ${REPO_DIRECTORY}/manage/.rsyncignore).
# If the running machine is itself part of the cluster (including being a master), self-sending is omitted.
# If it is not a master (e.g.  a remote develeoper machine, masters will also be targeted)


rsyncInstallationToCluster()
{

    local SCRIPT_DIRECTORY=$( readlink -f $( dirname $0 ))
    # repository directory is THREE folders above this script
    local REPO_DIRECTORY="$( readlink -f $( dirname $0 )/../../.. )"


    # recursive, compress during transfer, human readable, verbose, show progress, -e: specify remote shell (ssh)

    # don't sync files with names read from the following file
    local rsyncignoreFileName="${SCRIPT_DIRECTORY}/.rsyncignore"


    local openSpaceInstallDirectory=$( jq '.apps.Windows.OpenSpace.installDir' ${REPO_DIRECTORY}/config/apps.json | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )

    ## target dir must omit the last folder name
    local targetDir="$( readlink -f ${openSpaceInstallDirectory}/.. )"

    echo "OpenSpace Install SOURCE Directory to rsync to cluster: ${openSpaceInstallDirectory}"
    echo "OpenSpace install TARGET Directory to rsync to cluster: ${targetDir}"
    sleep 2


    ${REPO_DIRECTORY}/helpers/rsyncToCluster.sh --ignorefile "${rsyncignoreFileName}" --source-path "${openSpaceInstallDirectory}" --target-dir "${targetDir}" $@
    
}

rsyncInstallationToCluster $@