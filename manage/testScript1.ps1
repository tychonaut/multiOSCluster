#param( $par1, $par2 )

echo "this is the execution of POWERSHELL testScript 1 on $(whoami)!";

echo "first param to this script:"
$args[0]
echo "all params to this script: "
$args

echo "powershell exec policy: $(Get-ExecutionPolicy)"

dir

#sleep 4
