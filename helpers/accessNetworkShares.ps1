
$jsonCredentials=$(cat $PSScriptRoot/../config/credentials.json ) | ConvertFrom-Json


$index=0
while ($index -lt $jsonCredentials.credentials.NAS.count) {

	
	$driveletter=$jsonCredentials.credentials.NAS[$index].driveletter
	$address=$jsonCredentials.credentials.NAS[$index].address
	$foldername=$jsonCredentials.credentials.NAS[$index].foldername
	$domain=$jsonCredentials.credentials.NAS[$index].domain
	$username=$jsonCredentials.credentials.NAS[$index].username
	$password=$jsonCredentials.credentials.NAS[$index].password

	echo "command with drivelletter `" $($driveletter) `:`" with colon and double quotes, letter as json-parsed variable, and escaping the colon via `"```" "
	echo "this creates as lewast no error..."
	net use "$driveletter`:" \\$address\$foldername /user:$domain\$username $password /Y

	$index = $index + 1
}

#ls S:
