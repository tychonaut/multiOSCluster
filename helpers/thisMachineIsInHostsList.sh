#!/bin/bash

###############################################################################
# Parse master host names from JSON config, compare against own hostname.
#
# This logic is nececcary e.g. if files shall be distributed to the cluster.
# The sender can be a remote develepment machine that is NOT part of the cluster,
# not even a master machine. In this case, the master machine(s) have to be a TARGET
# of the transfer, not only the slaves.
# On the other hand, for on-site development, configuring and debugging,
# a master machine would be a SOURCE of the transfer, and making it also a target
# might result in terrible side effects. So we have to catch this case.
#
# This script prints "true" to stdout if the running machine is in the "masters" section of the config,
# "false" otherwise


# repository directory is one folder above this script
REPO_DIRECTORY="$( readlink -f $( dirname $0 )/.. )"


#------------------------------------
# usage example : /d/devel/scripts/multiOSCluster/helpers/thisIsMaster.sh /d/devel/scripts/multiOSCluster/config/hosts.json
thisMachineIsInCategory()
{
        local category=$1
        local hostsFilePath="${REPO_DIRECTORY}/config/hosts.json"
    

        local isInCat_ret="false"

        local activeOS=$( ${REPO_DIRECTORY}/helpers/getActiveOS.sh )


        local numNodes=$(jq ".hosts.${activeOS}.${category} | length" ${hostsFilePath})

        for (( i=0; i<${numNodes}; i++ )); do

            # parse JSON file using jq, strip leading and trailing double quotes with sed
            local currenthostname=$(jq ".hosts.${activeOS}.${category}[${i}].hostname" ${hostsFilePath} | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )
            
            if [[ "${currenthostname}" == $(hostname) ]]; then
                isInCat_ret="true"
            fi
        done

        echo "${isInCat_ret}"
}
#------------------------------------




#------------------------------------
thisMachineIsInHostsList()
{
    if [[ $(thisMachineIsInCategory "masters") == "true"  || $( thisMachineIsInCategory "slaves" ) == "true"  ]]; then
    
        echo "true"
        
    else
    
        echo "false"
    
    fi
}

thisMachineIsInHostsList