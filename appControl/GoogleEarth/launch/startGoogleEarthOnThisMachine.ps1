# PSTools help with the issue of logging into a command line shell from a remote computer
# and then wanting to launch a Program with a window; Somehow, PSTools "escape" the remote shell.

# Workaround for network shares with admin elevations, that avio somehow starts openspace with:
# https://superuser.com/questions/199387/elevated-command-line-prompt-cant-access-shared-drives
# the next command seems needed after a reboot:
D:\apps\PSTools\PsExec64.exe -i \\$(hostname) -d -s powershell.exe net use S: \\10.0.10.6\Shared /user:nasuser rackstation1 /Y

echo "launching Google Earth on $(hostname)..."

D:\apps\PSTools\PsExec64.exe -i \\$(hostname) -d -s "C:\Program Files\Google\Google Earth Pro\client\googleearth.exe"