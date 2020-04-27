#!/bin/bash 

# quick n dirty, have to do it right when tehere is time
 
commandString="/D/apps/PSTools/pskill OpenSpace" 
 
 
ssh ARENAMASTER+arena@arenamaster "${commandString}" &
 
ssh ARENART1+arena@arenart1 "${commandString}" &
ssh ARENART2+arena@arenart2 "${commandString}" &
ssh ARENART3+arena@arenart3 "${commandString}" &
ssh ARENART4+arena@arenart4 "${commandString}" &
ssh ARENART5+arena@arenart5 "${commandString}" &

echo "done killing"