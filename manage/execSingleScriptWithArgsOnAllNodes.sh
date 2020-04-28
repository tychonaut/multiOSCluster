#!/bin/sh




hostsFilePath="../config/hosts.json"



###############################################################################
# on which operating system are we?
activeOS="Windows";

if [[ "$OSTYPE" == "linux-gnu" ]]; then
	activeOS="Linux";
		
elif [[ "$OSTYPE" == "cygwin" ]]; then
        # POSIX compatibility layer and Linux environment emulation for Windows
	activeOS="Windows";
elif [[ "$OSTYPE" == "msys" ]]; then
        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
	activeOS="Windows";

#elif [[ "$OSTYPE" == "darwin"* ]]; then
#        # Mac OSX
#elif [[ "$OSTYPE" == "win32" ]]; then
#        # I'm not sure this can happen.
#elif [[ "$OSTYPE" == "freebsd"* ]]; then
#        # ...
else
        echo "OS type not supported: $OSTYPE"
		exit 1
fi


###############################################################################
# parse args
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

useMasters=0
useSlaves=0
selectionOptionFound=0

POSITIONAL=()
while [[ $# -gt 0 ]]
do
	key="$1"

	case $key in
		-h|--help)
		echo "usage: $0 [ [-h|--help] | [-a|--all] | [-m|--master|--masters] | [-s|--slaves] ] <scriptPath> <arg list to script>"
		echo "default behaviour is to execute <scriptPath> on all cluster nodes specified in ../config/hosts.json, including master(s) (-a)."
		echo "Note that in principal, there could be several master machines, though a single machine is most common."
		echo "usage example:  ./execSingleScriptWithArgsOnAllNodes.sh ./testScript1.sh argtoTestScript1 argtoTestScript2"
		exit 0
		shift # past argument

		;;
		-a|--all)
		useMasters=1
		useSlaves=1
		selectionOptionFound=1
		shift # past argument
		;;
		-m|--master|--masters)
		useMasters=1
		selectionOptionFound=1
		shift # past argument
		;;
		-s|--slaves)
		useSlaves=1
		selectionOptionFound=1
		shift # past argument
		;;
		
		*)    # unknown option
		POSITIONAL+=("$1") # save it in an array for later
		shift # past argument
		;;
	esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters to this script, i.e. $@

if [[ ${selectionOptionFound} == 0 ]]; then
	#default
	useMasters=1
	useSlaves=1
fi


scriptPath="${1}"
shift
scriptArgs="${@}"


###############################################################################
# parse host- and usernames
# 
# https://linuxconfig.org/how-to-parse-a-json-file-from-linux-command-line-using-jq


#--------------------
sshStrings_ret=()

createSSH_strings()
{
	sshStrings_ret=()
	
	#activeOS=
}
#--------------------


sshStrings=()

clusterCategories=()
if [[ ${useMasters} == 1 ]]; then
	clusterCategories+=("masters")
fi 
if [[ ${useSlaves} == 1 ]]; then
	clusterCategories+=("slaves")
fi 

for categIndex in ${!clusterCategories[@]}; do

	numNodes=$(jq ".hosts.${activeOS}.${clusterCategories[categIndex]} | length" ${hostsFilePath})
	for (( i=0; i<${numNodes}; i++ ));do
	
		hostname=$(jq ".hosts.${activeOS}.${clusterCategories[categIndex]}[${i}].hostname" ${hostsFilePath} | sed -e 's/^"//' -e 's/"$//' )
		username=$(jq ".hosts.${activeOS}.${clusterCategories[categIndex]}[${i}].username" ${hostsFilePath} | sed -e 's/^"//' -e 's/"$//' )

		sshStrings+=("${username}@${hostname}")
	done
	
done

#echo " SSH strings: ${sshStrings[@]}"



###############################################################################
# 


for index in ${!sshStrings[@]}; do
	echo "scp-ing ${scriptPath} to "${sshStrings[${index}]}" ..."
	scp "${scriptPath}" "${sshStrings[${index}]}":"${scriptPath}"	
		
	echo "ssh-ing to "${sshStrings[${index}]}" ..."
	ssh "${sshStrings[${index}]}" "${scriptPath} ${scriptArgs}"
done

echo "done scp and ssh"
