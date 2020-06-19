#!/bin/bash 

# Complicated workaround for this problem:
# https://social.microsoft.com/Forums/en-US/ac4b9271-103b-429a-8806-7c813a6131ee/connect-failed-access-is-denied-errno-5?forum=windowshpcmpi
#
# In own words: Microsofts MPI implementation (MS-MPI) only allows intercommunication among machines that have 
# the same user account+password active. If you want to launch a cluster of ParaView servers from a machine
# with a different account than the cluster machines, you are out of luck.
#
# The workaround is basically this:
# call paraview client 
# -> parse default_servers.pvsc
# -> call powershell on link to THIS bash script
# -> bash is opened 
# -> ssh to remote master
# -> on master via remote ssh bash session: enable network access via net use
# -> on master via remote ssh bash session: start psexec to escape "non-GUI"-restriction to:
# -> start mpiexec with  launch all pvserver-instances

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

    echo "TODO remove hardcoded paths!!11"

    #this one works 0o:
    ${REPO_DIRECTORY}/manage/performOnClusterNodes.sh --masters -NAS --execute-command "/D/apps/PSTools/PsExec64.exe -i -d \\\\\\\\\$(hostname) -h -u \$(${hostCredPath} username) -p \$(${hostCredPath} pw) mpiexec.exe -np 2 -machinefile D:\\\\apps\\\\ParaView\\\\v5.8.0_CAVE\\\\bin\\\\machines.txt  D:\\\\apps\\\\ParaView\\\\v5.8.0_CAVE\\\\bin\\\\pvserver.exe D:\\\\apps\\\\ParaView\\\\v5.8.0_CAVE\\\\bin\\\\dome_arena.pvx"


    echo "done launching MPI ParaView server on remote master, then cascading to cluster..."
    sleep 3

}


launchClusterServers ParaView

