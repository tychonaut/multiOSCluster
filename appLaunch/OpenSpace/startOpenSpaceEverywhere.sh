#!/bin/bash 

SCRIPT_DIRECTORY="$( readlink -f $( dirname $0 ))"
 # repository directory is two folders above this script's location
REPO_DIRECTORY="$( readlink -f ${SCRIPT_DIRECTORY}/../.. )"


${REPO_DIRECTORY}/manage/performOnClusterNodes.sh --all --execute-script  ${SCRIPT_DIRECTORY}/startOpenSpaceOnThisMachine.ps1






##!/bin/bash 
#
## quick n dirty, have to do it right when there is time
# 
#commandString="powershell.exe –ExecutionPolicy Bypass -File #D:\\\\devel\\\\OpenSpace\\\\OpenSpace_ownDeploy\\\\bin\\\\Release\\\\launchOpSpViaPSTools.ps1"
# 
##detach ssh sessions from main shell in order for the waiting time not to accumulate or if a host is unreachable
# 
#ssh ARENAMASTER+arena@arenamaster "${commandString}" &
# 
#ssh ARENART1+arena@arenart1 "${commandString}" &
#ssh ARENART2+arena@arenart2 "${commandString}" &
#ssh ARENART3+arena@arenart3 "${commandString}" &
#ssh ARENART4+arena@arenart4 "${commandString}" &
#ssh ARENART5+arena@arenart5 "${commandString}" &



echo "started openspace everywhere"
sleep 3
