echo "this is the execution of POWERSHELL testScript 1 on $(whoami)!";
echo "all params to this script: "
$args
echo "powershell exec policy: $(Get-ExecutionPolicy)"


ls S: