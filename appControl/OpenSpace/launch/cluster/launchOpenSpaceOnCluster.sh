#!/bin/bash 

SCRIPT_DIRECTORY="$( readlink -f $( dirname $0 ))"
 # repository directory is four folders above this script's location
REPO_DIRECTORY="$( readlink -f ${SCRIPT_DIRECTORY}/../../../.. )"


activeProfile=$( jq '.apps.Windows.OpenSpace.profile' ${REPO_DIRECTORY}/config/apps.json | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )
echo "active profile: $activeProfile"

echo "TODO rsync config and calib files to cluster depending on selected profile"

installDir_unixStyle=$( jq '.apps.Windows.OpenSpace.installDir' ${REPO_DIRECTORY}/config/apps.json | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )
installDir_windowsStyle=$( cygpath.exe -a -w -m "${installDir_unixStyle}" )

exe_unixStyle=$( jq '.apps.Windows.OpenSpace.executable' ${REPO_DIRECTORY}/config/apps.json | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )
exe_windowsStyle=$( cygpath.exe -w -m "${exe_unixStyle}" )


echo "installDir_windowsStyle: ${installDir_windowsStyle}"

echo "launching Openspace on cluster ..."
${REPO_DIRECTORY}/manage/performOnClusterNodes.sh --all --execute-script  ${SCRIPT_DIRECTORY}/../local/launchOpenSpaceLocally.ps1 --args "${installDir_windowsStyle}" "${exe_windowsStyle}"




echo "done launching Openspace on cluster ..."
sleep 3
