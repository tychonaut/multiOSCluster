
#change working directory to that of the script, to call sub-scripts with relative paths
#https://stackoverflow.com/questions/4724290/powershell-run-command-from-scripts-directory
$scriptpath = $MyInvocation.MyCommand.Path
$scriptdir = Split-Path $scriptpath
cd "$scriptdir"

.\rebootToSelectedOS "Windows"