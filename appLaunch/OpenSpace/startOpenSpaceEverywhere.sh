#!/bin/bash 

# quick n dirty, have to do it right when tehere is time
 
commandString="powershell.exe –ExecutionPolicy Bypass -File D:\\\\devel\\\\OpenSpace\\\\OpenSpace_ownDeploy\\\\bin\\\\Release\\\\launchOpSpViaPSTools.ps1"
 
#detach ssh sessions from main shell in order for the waiting time not to accumulate or if a host is unreachable
 
ssh ARENAMASTER+arena@arenamaster "${commandString}" &
 
ssh ARENART1+arena@arenart1 "${commandString}" &
ssh ARENART2+arena@arenart2 "${commandString}" &
ssh ARENART3+arena@arenart3 "${commandString}" &
ssh ARENART4+arena@arenart4 "${commandString}" &
ssh ARENART5+arena@arenart5 "${commandString}" &

echo "hopefully no crashes..."
sleep 3
