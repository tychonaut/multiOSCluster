#!/bin/bash 

# quick n dirty, have to do it right when tehere is time

# this one has issues; need to find a softer way to remotely shut down Google Earth.
# Maybe this one can help, though messy and dirty:
# https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-powershell-1.0/ff731008(v=technet.10)?redirectedfrom=MSDN
# won't waste more time with it for now... 
 
#GE refuses to shut down upon this signal, which is the common way to close a program gracefully.
#commandString="powershell 'TASKKILL.EXE /IM googleearth.exe'"

# Hence have to force the shutdown with the /F flag.
# This works for the killing, but often causes problems upon the next startup:
# There will be a prompt "wanna run trouble shooter" or so, which breaks the automation.
# Pretty annoaying behavior, considering GE being Liquid Galaxy's flag ship app
# for this clustered system.
#commandString="/D/apps/PSTools/pskill googleearth" 
commandString="powershell 'TASKKILL.EXE /IM googleearth.exe /F'"

 
 
ssh ARENAMASTER+arena@arenamaster "${commandString}" &
 
ssh ARENART1+arena@arenart1 "${commandString}" &
ssh ARENART2+arena@arenart2 "${commandString}" &
ssh ARENART3+arena@arenart3 "${commandString}" &
ssh ARENART4+arena@arenart4 "${commandString}" &
ssh ARENART5+arena@arenart5 "${commandString}" &

echo "done killing"