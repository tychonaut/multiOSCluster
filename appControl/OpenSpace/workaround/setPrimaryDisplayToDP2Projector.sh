#!/bin/bash 

# quick n dirty, have to do it right when tehere is time

# The numbers are hard codes, coming from the random nature of NVIDIA's display enumeration :(.
# They hence hay have to be adapted upon cable change, signal loss, rewiring etc.
# Best shot for keeping the mapping stable: Read the EDIDs into the GPU as soon a the cabling issues are settled (and hence the setting remains fixed in the forseable future).
 
#not neccecary for master
#ssh ARENAMASTER+arena@arenamaster "/D/apps/PSTools/PsExec64.exe -i \\\\$(hostname) -d -s  D:\\apps\\multimonitortool-x64\\MultiMonitorTool.exe //SetPrimary 2"

 echo "THIS SCRIPT $0 IS SO HACKY, FIX ASAP"
 
#ssh ARENART1+arena@arenart1 "/D/apps/PSTools/PsExec64.exe -i \\\\\\\\arenart1 -d -s  D:\\\\apps\\\\multimonitortool-x64\\\\MultiMonitorTool.exe //SetPrimary 3"
ssh ARENART2+arena@arenart2 "/D/apps/PSTools/PsExec64.exe -i \\\\\\\\arenart2 -d -s  D:\\\\apps\\\\multimonitortool-x64\\\\MultiMonitorTool.exe //SetPrimary 3"
ssh ARENART3+arena@arenart3 "/D/apps/PSTools/PsExec64.exe -i \\\\\\\\arenart3 -d -s  D:\\\\apps\\\\multimonitortool-x64\\\\MultiMonitorTool.exe //SetPrimary 2"
ssh ARENART4+arena@arenart4 "/D/apps/PSTools/PsExec64.exe -i \\\\\\\\arenart4 -d -s  D:\\\\apps\\\\multimonitortool-x64\\\\MultiMonitorTool.exe //SetPrimary 2"
ssh ARENART5+arena@arenart5 "/D/apps/PSTools/PsExec64.exe -i \\\\\\\\arenart5 -d -s D:\\\\apps\\\\multimonitortool-x64\\\\MultiMonitorTool.exe //SetPrimary 2"
