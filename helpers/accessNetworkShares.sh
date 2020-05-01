#!/bin/bash


# this is a "works for me"-kind of script. The Windows-msys-ssh-interactions aren't really understood by me. 
# I just googled and tried command permutations until it worked :(.
# WARNING: Always log out of a remote bash session using  "logout" (NOT "exit")! 
#          Otherwise, upon a new logon a new access to network shares may not work for several minutes!
#
# WARNING: Provide a domain to the NAS username, i.e. "GEOMAR\myUser" instead of "myUser"! 
# Otherwise, some REALLY inconsistent and volatile errors can occur sometimes
# (System error 1312 has occurred. A specified logon session does not exist. It may already have been terminated.)


# repository directory is one folder above this script's location
REPO_DIRECTORY="$( readlink -f $( dirname $0 )/.. )"


# workaround for problem that jq package in msys is only for mingw shell; 
# have to add mingw to PATH for non-interactive sessions (that don't laod a startup file)
PATH="/mingw64/bin/:$PATH"


accessNetworkShares()
{    
    ## not sure if this is neccessary:
    #powershell "net use * /delete /y"
    ## wait a while for the NAS to get ready
    #sleep 1
    
   
    local credentialsFilePath="${REPO_DIRECTORY}/config/credentials.json"
    
    stripper="${REPO_DIRECTORY}/helpers/stripLeadingAndTrailingQuotes.sh"
    
    local numShares=$(jq ".credentials.NAS | length" ${credentialsFilePath})	
    for (( i=0; i<${numShares}; i++ )); do
    
        local driveletter=$( jq ".credentials.NAS[${i}].driveletter" ${credentialsFilePath} | "${stripper}" )
        local address=$(     jq ".credentials.NAS[${i}].address"     ${credentialsFilePath} | "${stripper}" )
        local foldername=$(  jq ".credentials.NAS[${i}].foldername"     ${credentialsFilePath} | "${stripper}" )
        local domain=$(  jq ".credentials.NAS[${i}].domain"     ${credentialsFilePath} | "${stripper}" )
        local username=$(    jq ".credentials.NAS[${i}].username"    ${credentialsFilePath} | "${stripper}" )
        local password=$(    jq ".credentials.NAS[${i}].password"    ${credentialsFilePath} | "${stripper}" )
        

        echo "Binding network share \\\\${address}\\${foldername}; username: ${domain}\\${username}"

        net use /user:"${domain}\\${username}" "\\\\${address}\\${foldername}" ${password}
        
        # wait a while for the NAS to get ready
        sleep 1
        
    done
    
        
}

accessNetworkShares

