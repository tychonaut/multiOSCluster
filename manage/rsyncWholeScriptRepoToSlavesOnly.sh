#!/bin/bash

# Convenience script to quickly sync the current machine's (propably master) multiOSCluster-repository to all slaves;

SCRIPT_DIRECTORY="$(dirname $0 )"

${SCRIPT_DIRECTORY}/rsyncWholeScriptRepoToCluster.sh --slaves