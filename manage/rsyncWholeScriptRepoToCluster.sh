#!/bin/bash

# usage: $0 [ [-a|--all] | [-m|--master|--masters]  [-s|--slaves] ] 
# 


# repository directory is one folder above this script
REPO_DIRECTORY="$( readlink -f $( dirname $0 )/.. )"

# recursive, compress during transfer, human readable, verbose, show progress, -e: specify remote shell (ssh)

# don't sync files with names read from the following file
rsyncignoreFileName="${REPO_DIRECTORY}/manage/.rsyncignore"



clusterNodeTypeFlags=""
if [[ $# > 0 ]]; then
    clusterNodeTypeFlags=$1
fi


${REPO_DIRECTORY}/helpers/rsyncToCluster.sh ${clusterNodeTypeFlags} --ignorefile "${rsyncignoreFileName}" --source-path "${REPO_DIRECTORY}"