#!/bin/sh

#nodelist=["arenart1","arenart2","arenart3","arenart4","arenart5"]

#https://stackoverflow.com/questions/8880603/loop-through-an-array-of-strings-in-bash

declare -a hostnames=(
#	"arenart1"
#	"arenart2"
#	"arenart3"
	"arenart4"
#	"arenart5"
)

declare -a usernames=(
#	"ARENART1+arena"
#	"ARENART2+arena"
#	"ARENART3+arena"
	"ARENART4+arena"
#	"ARENART5+arena"
)

numNodes=${#hostnames[@]}
echo $numNodes

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
