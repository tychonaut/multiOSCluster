#!/bin/bash


# Workaround for PSexec


# workaround for problem that jq package in msys is only for mingw shell; 
# have to add mingw to PATH for non-interactive sessions (that don't laod a startup file)
PATH="/mingw64/bin/:$PATH"


# params: "username" or "pw"
getHostCreds()
{
    # repository directory is one folder above this script's location
    local REPO_DIRECTORY="$( readlink -f $( dirname $0 )/.. )"

    local key=$1
    
    #hardcode, sorry
    local credentialsFilePath="${HOME}/hostcredentials.json"
    local activeOS=$( ${REPO_DIRECTORY}/helpers/getActiveOS.sh )
    local stripper="${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh"
    

    local value_ret=$( jq ".${activeOS}.\"$(hostname)\".$1" ${credentialsFilePath} | "${stripper}" )
    
    echo $value_ret;
}

getHostCreds $@
exit 0
