#!/bin/bash

rsyncParaViewInstallDirToCluster()
{
    local SCRIPT_DIRECTORY="$( readlink -f $( dirname $0 ))"
     # repository directory is three folders above this script's location
    local REPO_DIRECTORY="$( readlink -f ${SCRIPT_DIRECTORY}/../../.. )"
    
    ${REPO_DIRECTORY}/appControl/rsyncAppInstallDirToCluster.sh ParaView
    
}

rsyncParaViewInstallDirToCluster