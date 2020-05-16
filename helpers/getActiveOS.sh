#!/bin/bash

#------------------------------------
# on which operating system are we?

#------------------------------------
getActiveOS()
{
	local activeOS_ret="Windows";
	#activeOS_ret="Windows";

	if [[ "$OSTYPE" == "linux-gnu" ]]; then
		activeOS="Linux";	
	elif [[ "$OSTYPE" == "cygwin" ]]; then
		# POSIX compatibility layer and Linux environment emulation for Windows
		activeOS="Windows";
	elif [[ "$OSTYPE" == "msys" ]]; then
		# Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
		activeOS="Windows";
	else
			echo "OS type not supported yet: $OSTYPE"
			exit 1
	fi
	
	echo "${activeOS_ret}"
}
#------------------------------------

getActiveOS