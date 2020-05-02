#!/bin/bash

# This script copies the whole contents of the multiOSCluster repository 
# to all the cluster machines specified in {REPO_DIRECTORY}/config/hosts.json including masters
# (without git meta files, which are excluded via ${REPO_DIRECTORY}/manage/.rsyncignore).
# If the running machine is itself part of the cluster (including being a master), self-sending is omitted.
# If it is not a master (e.g.  a remote develeoper machine, masters will also be targeted)


# repository directory is one folder above this script
REPO_DIRECTORY="$( readlink -f $( dirname $0 )/.. )"


# don't sync files with names read from the following file
rsyncignoreFileName="${REPO_DIRECTORY}/manage/.rsyncignore"


## target dir must omit the last folder name
targetDir="$( readlink -f ${REPO_DIRECTORY}/.. )"


#${REPO_DIRECTORY}/helpers/rsyncToCluster.sh ${clusterNodeTypeFlags} --ignorefile "${rsyncignoreFileName}" --source-path "${REPO_DIRECTORY}"
${REPO_DIRECTORY}/helpers/rsyncToCluster.sh --ignorefile "${rsyncignoreFileName}" --source-path "${REPO_DIRECTORY}" --target-dir "${targetDir}"