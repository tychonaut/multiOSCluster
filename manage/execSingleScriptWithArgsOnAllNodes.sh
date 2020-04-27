#!/bin/sh


#usage example:  ./execSingleScriptWithArgsOnAllNodes.sh ./testScript1.sh "this is my argument"

#https://stackoverflow.com/questions/8880603/loop-through-an-array-of-strings-in-bash

declare -a hostnames=(
	"arenamaster"
	"arenart1"
	"arenart2"
	"arenart3"
	"arenart4"
	"arenart5"
)

declare -a usernames=(
	"ARENAMASTER+arena"
	"ARENART1+arena"
	"ARENART2+arena"
	"ARENART3+arena"
	"ARENART4+arena"
	"ARENART5+arena"
)

numNodes=${#hostnames[@]}
echo ${numNodes}

echo "host names : ${hostnames[@]}"

scriptName=$1
shift


for (( i=0; i<${numNodes}; i++ ))
do

	ssh_string="${usernames[$i]}@${hostnames[$i]}"
		
	echo "scp-ing ${scriptName} to ${ssh_string} ..."
	scp "${scriptName}" "${ssh_string}":"${scriptName}"	
		
	echo "ssh-ing to ${ssh_string} ..."
	ssh "${ssh_string}" "${scriptName} $@"

done


echo "done ssh"


#scp /d/devel/scripts/multiOSCluster/manage/testScript1.sh ARENAMASTER+arena@arenamaster:/d/devel/scripts/multiOSCluster/manage/testScript1.sh
#scp testScript1.sh ARENAMASTER+arena@arenamaster:testScript1.sh