#!/bin/bash 


###############################################################################
#
usage()
{
    echo \
"Usage syntax: $0 KVM|warpedProjector|unwarpedProjector
   
Sets the primary display for each of the cluster's slave node to the specified one.  
This is needed as a workaround that must be applied before using applications that do not allow proper specification of display regions to render to, or that are buggy in this regard. 

The numerical values for the display IDs are stored in <multiOSCluster directory>/config/hosts.json .
These numerical values are  seemingly arbitrarily chosen by Nvidia upon each change on the display setup (even due to a loose connection).
Enforcing permanence by loading EDIDs into each Quadro GPU mitigates the problem, but keep in mind to update the values
each time the cabling or display change.

For each machine, the values have to be obtained from 'Nvidia control panel' -> 'set up multiple displays' and entered into the corresponding entry in <multiOSCluster directory>/config/hosts.json . 
"
}



###############################################################################
# parse args

displayType="invalid"

parseArgs()
{
    while [[ $# -gt 0 ]]
    do
        local key="${1}"
        case ${key} in
            -h|--help)
                usage
                exit 0
                shift # past argument
                ;;
            *)
                displayType="${1}"
                shift # past argument
                ;;
        esac
    done
}

###############################################################################
setPrimaryDisplay()
{
    parseArgs $@

    local SCRIPT_DIRECTORY="$( readlink -f $( dirname $0 ))"
     # repository directory is ONE folder above this script's location
    local REPO_DIRECTORY="$( readlink -f ${SCRIPT_DIRECTORY}/.. )"
	local activeOS=$( ${REPO_DIRECTORY}/helpers/getActiveOS.sh )
    local hostsFilePath="${REPO_DIRECTORY}/config/hosts.json"
    
    
    # for each slave node:
	local numNodes=$( jq ".hosts.${activeOS}.slaves | length" ${hostsFilePath} )

	for (( hostIndex=0; hostIndex < "${numNodes}"; hostIndex++ )); 
    do
		# (parse JSON file using jq, strip leading and trailing double quotes with sed)
        
        # get "ssh connection"strings for slave node
		local hostname=$(jq ".hosts.${activeOS}.slaves[${hostIndex}].hostname" ${hostsFilePath} | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )
		local username=$(jq ".hosts.${activeOS}.slaves[${hostIndex}].username" ${hostsFilePath} | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )
		sshString="${username}@${hostname}"
        
        local displayID=$(jq ".hosts.${activeOS}.slaves[${hostIndex}].displayIDs.${displayType}" ${hostsFilePath} | ${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh )
		
        # do the call with help of PsExec and MultiMonitorTool
        ssh "${sshString}" "/D/apps/PSTools/PsExec64.exe -i \\\\\\\\${hostname} -d -s  D:\\\\apps\\\\multimonitortool-x64\\\\MultiMonitorTool.exe //SetPrimary ${displayID}"
            
	done


}

#invoke above routine
setPrimaryDisplay $@


