#!/bin/bash

rsyncMoreVizInstallDirToCluster()
{
    local SCRIPT_DIRECTORY="$( readlink -f $( dirname $0 ))"
     # repository directory is three folders above this script's location
    local REPO_DIRECTORY="$( readlink -f ${SCRIPT_DIRECTORY}/../../.. )"
    
    echo "TODO extend rsyncAppInstallDirToCluster.sh with configDir and configDistributionMode"
    sleep 5
    exit 1
    
    
    ${REPO_DIRECTORY}/appControl/rsyncAppInstallDirToCluster.sh moreViz
    
}

rsyncMoreVizInstallDirToCluster
