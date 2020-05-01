#!/bin/bash 

SCRIPT_DIRECTORY="$( readlink -f $( dirname $0 ))"
 # repository directory is two folders above this script's location
REPO_DIRECTORY="$( readlink -f ${SCRIPT_DIRECTORY}/../.. )"


${REPO_DIRECTORY}/manage/performOnClusterNodes.sh --all --execute-script  ${SCRIPT_DIRECTORY}/killOpenSpaceOnThisMachine.ps1
