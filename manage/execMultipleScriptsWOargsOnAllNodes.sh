#!/bin/sh

# quick n dirty, have to do it right when there is time and if there comes nececcity for this script

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

scriptContents=""

for scriptName in "$@"
do

	echo "script name: ${scriptName}" 
	scriptContents="${scriptContents} $(cat ${scriptName})"
		
done

echo "combined script contents:"
echo "${scriptContents}"


for (( i=0; i<${numNodes}; i++ ))
do

	ssh_string="${usernames[$i]}@${hostnames[$i]}"
	echo "connecting to ${ssh_string} ..."
		
	ssh "${ssh_string}" <<-ENDSSH
		myName="$(whoami)"
		echo $myName
		
		echo "BEGIN executing script contents from on  remote host ${myName} :"
		echo
		
		eval "${scriptContents}"
		
		echo
		echo "END executing script contents from on  remote host ${myName}"
	ENDSSH

done

echo
echo "done ssh"
