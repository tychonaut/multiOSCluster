#!/bin/bash


# this is a "works for me"-kind of script. The Windows-msys-ssh-interactions aren't really understood by me. 
# I just googled and tried command permutations until it worked :(.
# WARNING: Always log out of a remote bash session using  "logout" (NOT "exit")! 
#          Otherwise, upon a new logon a new access to network shares may not work for several minutes!
#
# HINT:    If there is an error like:
#          "System error 1312 has occurred. A specified logon session does not exist. It may already have been terminated.",
#          then either wait for several minutes or try fixing it via something like:
#          ssh <corrupted machine>  "powershell \"net use * /delete /y\""



accessNetworkShares()
{    
    # original command that works in msys2 remote ssh bash sessions:
    #   net use /user:"xxx" '\\10.0.10.6\Shared' xxx
    # The above doesn't work when put into a command string; 
    # I suspect bash's handling of single quotes, that is different from handling of double quotes.
    # So, omit the single quotes. As a result, we have to escape every backslash twice!
    #   net use /user:"xxx" \\\\10.0.10.6\\Shared xxx



    powershell "net use * /delete /y"
    # wait a while for the NAS to get ready
    sleep 1
    
    username="xxx"
    password="xxx"
    #sharedFolderName="S:" # unused, somewhere already  implicitly stored
    #sharedFolderAddress="\\\\\\\\10.0.10.6\\\\Shared"
    sharedFolderAddress="\\\\10.0.10.6\\Shared" 

    ##somehow, this does not work :(   
    #commandString="net use /user:\"${username}\" ${sharedFolderAddress} ${password}"    
    ##execute this command
    #${commandString}


    #so intead, execute directly; This works:
    net use /user:"${username}" ${sharedFolderAddress} ${password}
    
    # wait a while for the NAS to get ready
    sleep 1
        
}

accessNetworkShares

