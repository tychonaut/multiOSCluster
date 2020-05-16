#!/bin/bash 

#jq-on-mys-workaround
PATH="/d/apps/PSTools:/mingw64/bin/:$PATH"


launchClusterServers()
{
    local appName="${1}"
    
    local SCRIPT_DIRECTORY="$( readlink -f $( dirname $0 ))"
     # repository directory is four folders above this script's location
    local REPO_DIRECTORY="$( readlink -f ${SCRIPT_DIRECTORY}/../../../.. )"

    echo " launching MPI paraview server on remote master, then cascading to cluster..."

    local exe_unixStyle="/D/apps/ParaView/v5.8.0_CAVE/bin/launchClusterServers.ps1"
    local exe_windowsStyle=$( cygpath.exe -w -m "${exe_unixStyle}" )

    #parse OS credentials:
    # this construct requires the whole script repo to reside on each computer, and in the same directory!
    local hostCredPath="${REPO_DIRECTORY}/helpers/getHostCreds.sh"


    #this one works 0o:
    ${REPO_DIRECTORY}/manage/performOnClusterNodes.sh --masters -NAS --execute-command "/D/apps/PSTools/PsExec64.exe -i -d \\\\\\\\\$(hostname) -h -u \$(${hostCredPath} username) -p \$(${hostCredPath} pw) mpiexec.exe -np 2 -machinefile D:\\\\apps\\\\ParaView\\\\v5.8.0_CAVE\\\\bin\\\\machines.txt  D:\\\\apps\\\\ParaView\\\\v5.8.0_CAVE\\\\bin\\\\pvserver.exe D:\\\\apps\\\\ParaView\\\\v5.8.0_CAVE\\\\bin\\\\dome_arena.pvx"


    echo "done launching MPI paravie server on remote master, then cascading to cluster..."
    sleep 3

}


launchClusterServers ParaView

