#!/bin/bash 

#jq-on-mys-workaround
PATH="/d/apps/PSTools:/mingw64/bin/:$PATH"

rebootAllSlavesToWindows()
{
	local SCRIPT_DIRECTORY="$( readlink -f $( dirname $0 ))"
	# repository directory is TWO folders above this script's location
	local REPO_DIRECTORY="$( readlink -f ${SCRIPT_DIRECTORY}/../.. )"
	
	${REPO_DIRECTORY}/manage/performOnClusterNodes.sh --slaves --execute-command "cd ${SCRIPT_DIRECTORY}; powershell ./rebootToWindows.ps1"
}


rebootAllSlavesToWindows