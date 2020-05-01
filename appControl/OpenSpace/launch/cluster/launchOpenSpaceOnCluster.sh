#!/bin/bash 

SCRIPT_DIRECTORY="$( readlink -f $( dirname $0 ))"
 # repository directory is four folders above this script's location
REPO_DIRECTORY="$( readlink -f ${SCRIPT_DIRECTORY}/../../../.. )"


echo "starting Openspace everywhere ..."

${REPO_DIRECTORY}/manage/performOnClusterNodes.sh --all --execute-script  ${SCRIPT_DIRECTORY}/../local/launchOpenSpaceLocally.ps1


echo "done starting Openspace everywhere"
sleep 3