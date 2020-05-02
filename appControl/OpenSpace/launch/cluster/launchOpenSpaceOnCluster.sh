#!/bin/bash 

SCRIPT_DIRECTORY="$( readlink -f $( dirname $0 ))"
 # repository directory is four folders above this script's location
REPO_DIRECTORY="$( readlink -f ${SCRIPT_DIRECTORY}/../../../.. )"

echo "launching OpenSpace on cluster ...."


activeProfile=$( jq '.apps.Windows.OpenSpace.profile' ${REPO_DIRECTORY}/config/apps.json | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )
echo "active profile: ${activeProfile}"


installDir_unixStyle=$( jq '.apps.Windows.OpenSpace.installDir' ${REPO_DIRECTORY}/config/apps.json | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )
installDir_windowsStyle=$( cygpath.exe -a -w -m "${installDir_unixStyle}" )

exe_unixStyle=$( jq '.apps.Windows.OpenSpace.executable' ${REPO_DIRECTORY}/config/apps.json | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )
exe_windowsStyle=$( cygpath.exe -w -m "${exe_unixStyle}" )


echo "installation directory: ${installDir_windowsStyle}"
echo "executable: ${installDir_windowsStyle}"


#trailing / might be necessyry this time...?
sourcePath="${REPO_DIRECTORY}/appControl/OpenSpace/profiles/${activeProfile}/"
rsyncignoreFilePath="${SCRIPT_DIRECTORY}/.rsyncignore"




echo "copying locally from ${sourcePath}/* to ${installDir_unixStyle} , via rsync, as cp -r behaves differently..."
## argh those trailing slashes...
#cp -r "${sourcePath}"  "${installDir_unixStyle}/"
##cp -r /d/devel/scripts/multiOSCluster/appControl/OpenSpace/profiles/debug/* /d/apps/OpenSpace/v0.15.1_git_arena/
rsync -r -z  -h -v --progress --exclude-from="${rsyncignoreFilePath}"  "${sourcePath}"  "${installDir_unixStyle}"



echo "rsyncing  config and calib files to cluster: source directory : ${sourcePath} ; target directory : ${installDir_unixStyle}"


${REPO_DIRECTORY}/helpers/rsyncToCluster.sh --ignorefile "${rsyncignoreFilePath}" --source-path "${sourcePath}" --target-dir "${installDir_unixStyle}"





echo "launching Openspace on cluster ..."
${REPO_DIRECTORY}/manage/performOnClusterNodes.sh --all --execute-script  ${SCRIPT_DIRECTORY}/../local/launchOpenSpaceLocally.ps1 --args "${installDir_windowsStyle}" "${exe_windowsStyle}"




echo "done launching Openspace on cluster ..."
sleep 3
