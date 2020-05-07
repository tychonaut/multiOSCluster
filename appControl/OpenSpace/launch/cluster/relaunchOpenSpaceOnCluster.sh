#!/bin/bash 
 
 
relaunchOpenSpaceOnCluster()
{
 
    local SCRIPT_DIRECTORY="$( readlink -f $( dirname $0 ))"
     # repository directory is four folders above this script's location
    local REPO_DIRECTORY="$( readlink -f ${SCRIPT_DIRECTORY}/../../../.. )"
     
    ${SCRIPT_DIRECTORY}/killOpenSpaceOnCluster.sh
    sleep 5
    ${SCRIPT_DIRECTORY}/launchOpenSpaceOnCluster.sh
    
}


relaunchOpenSpaceOnCluster