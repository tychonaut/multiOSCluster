#!/bin/sh




hostsFilePath="/d/devel/scripts/multiOSCluster/config/hosts.json"


###############################################################################
#
usage()
{
	echo "Usage syntax: $0 [ [-h|--help] | [-a|--all] | [-m|--master|--masters] | [-s|--slaves] ] --scriptPath <scriptPath>  [ --  <arg list to script>]"
	echo "Usage example:  $0 --scriptPath ./testScript1.sh -- argtoTestScript1 argtoTestScript2"
	echo "Description: This script executes the script *contents* of the 'payload script' <scriptPath> remotely on each machine specified in ${hostsFilePath} with the parameters following the '--'."
	echo "             Note the implication that only scripts work that do not rely on their own filename or a specific working directory! Contents will be executed in the remote's 'home' directory," 
	echo "             i.e. /home/<username>/ on Linux and  C:\\msys64\\home\\<username> on windows!"
	echo "The default behaviour is to execute <scriptPath> on all cluster nodes specified in ${hostsFilePath}, including master(s) (option '-a')."
	echo "Also note that in principal, there could be several master machines, though a single machine is most common."
}


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
else
        echo "OS type not supported: $OSTYPE"
		exit 1
fi


###############################################################################
# parse args
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash


useMasters=0
useSlaves=0
nodeTypeSelectionFound=0

scriptPath=""
scriptArgs=""



while [[ $# -gt 0 ]]
do
	key="$1"

	case $key in
		-h|--help)
		usage
		exit 0
		shift # past argument
		;;
		
		-a|--all)
		useMasters=1
		useSlaves=1
		nodeTypeSelectionFound=1
		shift # past argument
		;;
		-m|--master|--masters)
		useMasters=1
		nodeTypeSelectionFound=1
		shift # past argument
		;;
		-s|--slaves)
		useSlaves=1
		nodeTypeSelectionFound=1
		shift # past argument
		;;
		
		--scriptPath)
		shift # past argument
		scriptPath="${1}"
		shift # past value
		;;
		
		--)
		shift # past argument
		scriptArgs="${@}"
		break
		;;
		
		*)    # unknown param,  implies incorrect use here
		usage
		exit 0
		#POSITIONAL+=("$1") # save it in an array for later
		#shift # past argument
		;;
	esac
done
#set -- "${POSITIONAL[@]}" # restore positional parameters to this script, i.e. $@

if [[ ${nodeTypeSelectionFound} == 0 ]]; then
	#default: use all node types
	useMasters=1
	useSlaves=1
fi
if [[ ${scriptPath} == "" ]]; then
	echo "error: no script path provided"
	exit 1
fi






###############################################################################
# parse host- and usernames, construct strings used in ssh and scp
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
	for (( i=0; i<${numNodes}; i++ )); do
	
		# parse JSON file using jq, strip leading and trailing double quotes with sed
		hostname=$(jq ".hosts.${activeOS}.${clusterCategories[categIndex]}[${i}].hostname" ${hostsFilePath} | sed -e 's/^"//' -e 's/"$//' )
		username=$(jq ".hosts.${activeOS}.${clusterCategories[categIndex]}[${i}].username" ${hostsFilePath} | sed -e 's/^"//' -e 's/"$//' )

		sshStrings+=("${username}@${hostname}")
	done
	
done

#echo " SSH strings: ${sshStrings[@]}"






###############################################################################
# do the remote execution via SSH



##-----------------------------------
## approach 1: copy script, then execute; gets complicated if target directory does not exist, also pollutes remote machine

#for index in ${!sshStrings[@]}; do
#	echo "scp-ing ${scriptPath} to "${sshStrings[${index}]}" ..."
#	scp "${scriptPath}" "${sshStrings[${index}]}":"${scriptPath}"	
#		
#	echo "ssh-ing to "${sshStrings[${index}]}" ..."
#	ssh "${sshStrings[${index}]}" "${scriptPath} ${scriptArgs}"
#done
##--------------------------




#-----------------------------------
# approach 2: execute script in-place (at least for bash )

scriptContents=$(cat ${scriptPath})


scriptFileName="${scriptPath##*/}"
scriptFileExtension="${scriptFileName##*.}"
#scriptFileNameWoExtension="${scriptFileName%.*}"

#echo "scriptPath : ${scriptPath}"
#echo "scriptFileName : ${scriptFileName}"
#echo "scriptFileExtension : ${scriptFileExtension}"
#echo "scriptFileNameWoExtension : ${scriptFileNameWoExtension}"


echo "scriptArgs: ${scriptArgs}"

for index in ${!sshStrings[@]}; do

	echo "ssh-ing to "${sshStrings[${index}]}" with in-place-execution of script contents:"
	
	if 	 [[ "${scriptFileExtension}" == "sh" ]]; then
	
		# It's a (ba)sh script; execute contents in-place after args are passed via "set -- "
		
		ssh "${sshStrings[${index}]}" <<-ENDSSH
			set -- "${scriptArgs[@]}" 
			${scriptContents}
		ENDSSH
		
	elif [[ "${scriptFileExtension}" == "ps1" ]]; then
	
		# It's a powershell script; special treatment in order to make param passing work:
		# scp the payload script to a temporary remote script file.

		scp "${scriptPath}" "${sshStrings[${index}]}":temporaryScript.ps1

		# Then ssh into remote with the following 3-line inline code:
		ssh "${sshStrings[${index}]}" <<-ENDSSH
			set -- "${scriptArgs[@]}"
			powershell –ExecutionPolicy Bypass ./temporaryScript.ps1 $@
			rm ./temporaryScript.ps1
		ENDSSH

	else
        echo "script file extension type not yet supported: ${scriptFileExtension}"
		exit 1
	fi
	
done
#--------------------------

echo "done scp and ssh"
exit 0
