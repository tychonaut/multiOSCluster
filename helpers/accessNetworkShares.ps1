
$jsonCredentials=$(cat $PSScriptRoot/../config/credentials.json ) | ConvertFrom-Json

$index=0

$driveletter=$jsonCredentials.credentials.NAS[$index].driveletter
$address=$jsonCredentials.credentials.NAS[$index].address
$foldername=$jsonCredentials.credentials.NAS[$index].foldername
$domain=$jsonCredentials.credentials.NAS[$index].domain
$username=$jsonCredentials.credentials.NAS[$index].username
$password=$jsonCredentials.credentials.NAS[$index].password


# original command ths works:
# D:\apps\PSTools\PsExec64.exe -i \\$(hostname) -d -s powershell.exe net use S: \\10.0.10.6\Shared /user:nasuser rackstation1 /Y
# stripped from PsTools overhead:
#net use S: \\10.0.10.6\Shared /user:nasuser rackstation1 /Y

# this one works
#net use \\10.0.10.6\Shared /user:GEOMAR\nasuser rackstation1 /Y

net use \\$address\$foldername /user:$domain\$username $password /Y

ls S:
