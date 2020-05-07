#!/bin/bash 

#jq-on-mys-workaround
PATH="/d/apps/PSTools:/mingw64/bin/:$PATH"


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



##{
#echo "copying locally from ${sourcePath}/* to ${installDir_unixStyle} , via rsync, as cp -r behaves differently..."
### argh those trailing slashes...
##cp -r "${sourcePath}"  "${installDir_unixStyle}/"
###cp -r /d/devel/scripts/multiOSCluster/appControl/OpenSpace/profiles/debug/* /d/apps/OpenSpace/v0.15.1_git_arena/
#rsync -r -z  -h -v --progress --exclude-from="${rsyncignoreFilePath}"  "${sourcePath}"  "${installDir_unixStyle}"#
#
#echo "rsyncing  config and calib files to cluster: source directory : ${sourcePath} ; target directory : ${installDir_unixStyle}"
#${REPO_DIRECTORY}/helpers/rsyncToCluster.sh --ignorefile "${rsyncignoreFilePath}" --source-path "${sourcePath}" --target-dir "${installDir_unixStyle}"
##}




echo "launching Openspace on cluster ..."

#wftz: on master, it needs another flag than on the rest...?" YES, for whatever f***ed-up reasons! THE FOLLOWING WORKS! (for now, untilk next reboot/rename, whatever ...)
# so differentiate:

${REPO_DIRECTORY}/manage/performOnClusterNodes.sh --masters -NAS --execute-command "/D/apps/PSTools/PsExec64.exe -i -d \\\\\\\\\$(hostname) -h -s  ${installDir_windowsStyle}/${exe_windowsStyle}"

#parse OS credentials:
# this construct requires the whole script repo to reside on each computer, and in the same directory!
hostCredPath="${REPO_DIRECTORY}/helpers/getHostCreds.sh"
${REPO_DIRECTORY}/manage/performOnClusterNodes.sh --slaves -NAS --execute-command "/D/apps/PSTools/PsExec64.exe -i -d \\\\\\\\\$(hostname) -h -u \$(${hostCredPath} username) -p \$(${hostCredPath} pw) ${installDir_windowsStyle}/${exe_windowsStyle}"




echo "done launching Openspace on cluster ..."
sleep 3
