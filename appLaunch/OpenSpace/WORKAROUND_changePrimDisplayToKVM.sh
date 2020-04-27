#!/bin/bash 

# quick n dirty, have to do it right when tehere is time
 
#not neccecary for master
#ssh ARENAMASTER+arena@arenamaster "/D/apps/PSTools/PsExec64.exe -i \\\\$(hostname) -d -s  D:\\apps\\multimonitortool-x64\\MultiMonitorTool.exe //SetPrimary 1"
 
ssh ARENART1+arena@arenart1 "/D/apps/PSTools/PsExec64.exe -i \\\\\\\\arenart1 -d -s  D:\\\\apps\\\\multimonitortool-x64\\\\MultiMonitorTool.exe //SetPrimary 1"
ssh ARENART2+arena@arenart2 "/D/apps/PSTools/PsExec64.exe -i \\\\\\\\arenart2 -d -s  D:\\\\apps\\\\multimonitortool-x64\\\\MultiMonitorTool.exe //SetPrimary 1"
ssh ARENART3+arena@arenart3 "/D/apps/PSTools/PsExec64.exe -i \\\\\\\\arenart3 -d -s  D:\\\\apps\\\\multimonitortool-x64\\\\MultiMonitorTool.exe //SetPrimary 1"
ssh ARENART4+arena@arenart4 "/D/apps/PSTools/PsExec64.exe -i \\\\\\\\arenart4 -d -s  D:\\\\apps\\\\multimonitortool-x64\\\\MultiMonitorTool.exe //SetPrimary 1"
ssh ARENART5+arena@arenart5 "/D/apps/PSTools/PsExec64.exe -i \\\\\\\\arenart5 -d -s D:\\\\apps\\\\multimonitortool-x64\\\\MultiMonitorTool.exe //SetPrimary 1"