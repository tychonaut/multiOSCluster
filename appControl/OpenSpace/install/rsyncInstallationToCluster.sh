#!/bin/bash

# This script copies the whole contents of the multiOSCluster repository 
# to all the cluster machines specified in {REPO_DIRECTORY}/config/hosts.json including masters
# (without git meta files, which are excluded via ${REPO_DIRECTORY}/manage/.rsyncignore).
# If the running machine is itself part of the cluster (including being a master), self-sending is omitted.
# If it is not a master (e.g.  a remote develeoper machine, masters will also be targeted)

SCRIPT_DIRECTORY=$( readlink -f $( dirname $0 ))
# repository directory is THREE folders above this script
REPO_DIRECTORY="$( readlink -f $( dirname $0 )/../../.. )"


# recursive, compress during transfer, human readable, verbose, show progress, -e: specify remote shell (ssh)

# don't sync files with names read from the following file
rsyncignoreFileName="${SCRIPT_DIRECTORY}/.rsyncignore"


openSpaceInstallDirectory=$( jq '.apps.Windows.OpenSpace.installDir' ${REPO_DIRECTORY}/config/apps.json | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )


echo "OpenSpace Install Directory to rsync to cluster: ${openSpaceInstallDirectory}"
sleep 3

#${REPO_DIRECTORY}/helpers/rsyncToCluster.sh ${clusterNodeTypeFlags} --ignorefile "${rsyncignoreFileName}" --source-path "${REPO_DIRECTORY}"
${REPO_DIRECTORY}/helpers/rsyncToCluster.sh --ignorefile "${rsyncignoreFileName}" --source-path "${openSpaceInstallDirectory}"