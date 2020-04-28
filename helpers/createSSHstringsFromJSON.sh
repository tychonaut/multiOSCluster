#!/bin/bash

###############################################################################
# parse host- and usernames, construct strings used in ssh and scp
# 
# https://linuxconfig.org/how-to-parse-a-json-file-from-linux-command-line-using-jq



REPO_DIR="/d/devel/scripts/multiOSCluster"


#------------------------------------
# usage example : createSSH_strings "${hostsFilePath}" "${useMasters}" "${useSlaves}"
createSSH_strings()
{
	local hostsFilePath=$1
	local useMasters=$2
	local useSlaves=$3

	local sshStrings_ret=()
	
	local activeOS=$( ${REPO_DIR}/helpers/getActiveOS.sh )
	
	local clusterCategories=()

	if [[ ${useMasters} == 1 ]]; then
		clusterCategories+=("masters")
	fi 
	if [[ ${useSlaves} == 1 ]]; then
		clusterCategories+=("slaves")
	fi 
	
	for categIndex in ${!clusterCategories[@]}; do

		local numNodes=$(jq ".hosts.${activeOS}.${clusterCategories[categIndex]} | length" ${hostsFilePath})
		
		for (( i=0; i<${numNodes}; i++ )); do
		
			# parse JSON file using jq, strip leading and trailing double quotes with sed
			local hostname=$(jq ".hosts.${activeOS}.${clusterCategories[categIndex]}[${i}].hostname" ${hostsFilePath} | sed -e 's/^"//' -e 's/"$//' )
			local username=$(jq ".hosts.${activeOS}.${clusterCategories[categIndex]}[${i}].username" ${hostsFilePath} | sed -e 's/^"//' -e 's/"$//' )
			sshStrings_ret+=("${username}@${hostname}")
		done
		
	done

	echo "${sshStrings_ret[@]}"
}
#------------------------------------

createSSH_strings $@