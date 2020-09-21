#!/bin/bash

rsyncAppConfigLocally()
{
    local SCRIPT_DIRECTORY="$( readlink -f $( dirname $0 ))"
    
    ${SCRIPT_DIRECTORY}/rsyncAppConfigToCluster.sh "$@" --local-only
}

rsyncAppConfigLocally "$@"