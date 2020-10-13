#!/bin/bash

rsyncMoreVizConfigToCluster()
{
    local SCRIPT_DIRECTORY="$( readlink -f $( dirname $0 ))"
     # repository directory is three folders above this script's location
    local REPO_DIRECTORY="$( readlink -f ${SCRIPT_DIRECTORY}/../../.. )"
    
    echo "TODO extend rsyncAppConfigToCluster.sh with configDir and configDistributionMode"
    sleep 5
    exit 1
    
    ${REPO_DIRECTORY}/appControl/rsyncAppConfigToCluster.sh moreViz
    
}

rsyncMoreVizConfigToCluster
