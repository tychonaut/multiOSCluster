
$jsonCredentials=$(cat $PSScriptRoot/../config/credentials.json ) | ConvertFrom-Json


$index=0
while ($index -lt $jsonCredentials.credentials.NAS.count) {

	
	$driveletter=$jsonCredentials.credentials.NAS[$index].driveletter
	$address=$jsonCredentials.credentials.NAS[$index].address
	$foldername=$jsonCredentials.credentials.NAS[$index].foldername
	$domain=$jsonCredentials.credentials.NAS[$index].domain
	$username=$jsonCredentials.credentials.NAS[$index].username
	$password=$jsonCredentials.credentials.NAS[$index].password


	# original command that works:
	#D:\apps\PSTools\PsExec64.exe -i \\$(hostname) -d -s powershell.exe net use S: \\10.0.10.6\Shared /user:nasuser rackstation1 /Y
	# stripped from PsTools overhead:
	#net use S: \\10.0.10.6\Shared /user:nasuser rackstation1 /Y

	# this one works
	#net use \\10.0.10.6\Shared /user:GEOMAR\nasuser rackstation1 /Y

	#echo "performing command: net use \\$address\$foldername /user:$domain\$username $password /Y"
	#net use \\$address\$foldername /user:$domain\$username $password /Y

	echo "I'm really desparate with windows remote gui app launch an network access: tryoing various hardcoded whingt on with PSTools\PsExec64.exe":
	
#	echo "performing command: net use \\$address\$foldername /user:$domain\$username $password /Y"
#	net use \\$address\$foldername /user:$domain\$username $password /Y
#	
#	echo "same command with drivelletter S: with colon"
#	net use S: \\$address\$foldername /user:$domain\$username $password /Y
#	echo "same command with drivelletter S without colon"
#	net use S \\$address\$foldername /user:$domain\$username $password /Y
#	echo "same command with drivelletter `"S:`" with colon and double quotes"
#	net use "S:" \\$address\$foldername /user:$domain\$username $password /Y
#	echo "same command with drivelletter `"S`" without colon, but with double quotes"
#	net use "S" \\$address\$foldername /user:$domain\$username $password /Y
#	
#	
#	#echo "same command with drivelletter $driveletter: with colon, letter as json parse variable"
#	#net use $driveletter: \\$address\$foldername /user:$domain\$username $password /Y
#	echo "same command with drivelletter S without colon, letter as json parse variable"
#	net use $driveletter \\$address\$foldername /user:$domain\$username $password /Y
#	#echo "same command with drivelletter `"S:`" with colon and double quotes, letter as json parse variable"
#	#net use "$driveletter:" \\$address\$foldername /user:$domain\$username $password /Y
#	echo "same command with drivelletter `"S`" without colon, but with double quotes, letter as json parse variable"
#	net use "$driveletter" \\$address\$foldername /user:$domain\$username $password /Y
	
	echo "same command with drivelletter `" $($driveletter) `:`" with colon and double quotes, letter as json parse variable and esaping the colon"
	echo "this creates as lewast no error..."
	net use "$driveletter`:" \\$address\$foldername /user:$domain\$username $password /Y

	$index = $index + 1
}

#ls S:
