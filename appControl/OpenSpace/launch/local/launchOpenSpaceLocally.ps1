param (
    [string]$installDir = "D:/apps/OpenSpace/v0.15.1_git_arena/",
	[string]$exeToLaunch = "bin/OpenSpace.exe"
 )


# PSTools help with the issue of logging into a command line shell from a remote computer
# and then wanting to launch a Program with a window; Somehow, PSTools "escape" the remote shell.


echo "installDir: $installDir"
echo "exeToLaunch: $exeToLaunch"



# Workaround for network shares with admin elevations, that avio somehow starts openspace with:
# https://superuser.com/questions/199387/elevated-command-line-prompt-cant-access-shared-drives
# the next command seems needed after a reboot:

#echo "enabling access to network share S:"
#D:\apps\PSTools\PsExec64.exe -i \\$(hostname) -d -s powershell.exe net use S: \\10.0.10.6\Shared /user:nasuser rackstation1 /Y
D:\apps\PSTools\PsExec64.exe -i \\$(hostname) -s powershell.exe $PSScriptRoot\..\..\..\..\helpers\accessNetworkShares.ps1

echo "launching OpenSpace on $(hostname)..."
#D:\apps\PSTools\PsExec64.exe -i \\$(hostname) -d -s D:\devel\OpenSpace\OpenSpace_ownDeploy\bin\Release\OpenSpace.exe
#D:\apps\PSTools\PsExec64.exe -i \\$(hostname) -d -s $installDir/$exeToLaunch

D:\apps\PSTools\PsExec64.exe -i \\$(hostname) -d -s $installDir/$exeToLaunch

#D:\apps\PSTools\PsExec64.exe -i \\$(hostname) -d -s D:/apps/OpenSpace/v0.15.1_git_arena/bin/OpenSpace.exeD:\apps\PSTools\PsExec64.exe -i \\$(hostname) -d  D:/apps/OpenSpace/v0.15.1_git_arena/bin/OpenSpace.exe

#D:\apps\PSTools\PsExec64.exe -i \\$(hostname) -d  D:/apps/OpenSpace/v0.15.1_git_arena/bin/OpenSpace.exe