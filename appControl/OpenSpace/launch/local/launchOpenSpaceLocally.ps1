param (
    [string]$installDir = "D:/devel/OpenSpace/OpenSpace_ownDeploy",
	[string]$exeToLaunch = "bin/Release/OpenSpace.exe"
 )


# PSTools help with the issue of logging into a command line shell from a remote computer
# and then wanting to launch a Program with a window; Somehow, PSTools "escape" the remote shell.


echo "installDir: $installDir"
echo "exeToLaunch: $exeToLaunch"



# Workaround for network shares with admin elevations, that avio somehow starts openspace with:
# https://superuser.com/questions/199387/elevated-command-line-prompt-cant-access-shared-drives
# the next command seems needed after a reboot:

echo "enabling access to network share S:"

##this one seems to work on old deploy on all but rt4, which i had restarted... tso well possible that nothing of this works
#D:\apps\PSTools\PsExec64.exe -i \\$(hostname) -d -s powershell.exe $PSScriptRoot\..\..\..\..\helpers\accessNetworkShares.ps1
#echo "launching OpenSpace on $(hostname)..."
##this one seems to work on old deploy on all but rt4, which i had restarted... tso well possible that nothing of this works
#D:\apps\PSTools\PsExec64.exe -i \\$(hostname) -d -s $installDir/$exeToLaunch


echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo " desperation"

ls S:

#D:\apps\PSTools\PsExec64.exe -i \\$(hostname) -u $(hostname)\arena -p xxx powershell.exe $PSScriptRoot\..\..\..\..\helpers\accessNetworkShares.ps1
D:\apps\PSTools\PsExec64.exe -i -d \\$(hostname) -u arena -p xxx powershell.exe $PSScriptRoot\..\..\..\..\helpers\accessNetworkShares.ps1
#D:\apps\PSTools\PsExec64.exe -i -d \\$(hostname) -s powershell.exe $PSScriptRoot\..\..\..\..\helpers\accessNetworkShares.ps1
echo "launching OpenSpace on $(hostname) WITH NON-SYSTEM-USER!!1111 ..."
# desperation
#D:\apps\PSTools\PsExec64.exe -i \\$(hostname) -u $(hostname)\arena -p xxx $installDir/$exeToLaunch
#D:\apps\PSTools\PsExec64.exe -i \\$(hostname) -u arena -p xxx $installDir/$exeToLaunch
#D:\apps\PSTools\PsExec64.exe -i  \\$(hostname) -s $installDir/$exeToLaunch
D:\apps\PSTools\PsExec64.exe -i -d \\$(hostname) -s $installDir/$exeToLaunch
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"