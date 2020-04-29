#!/bin/bash


# this is a "works for me"-kind of script. The Windows-msys-ssh-interactions aren't really understood by me. 
# I just googled and tried command permutations until it worked :(.
# WARNING: Always log out of a remote bash session using  "logout" (NOT "exit")! 
#          Otherwise, upon a new logon a new access to network shares may not work for several minutes!

accessNetworkShares()
{    
    # original command that works in msys2 remote ssh bash sessions:
    #   net use /user:"xxx" '\\10.0.10.6\Shared' xxx
    # The above doesn't work when put into a command string; 
    # I suspect bash's handling of single quotes, that is different from handling of double quotes.
    # So, omit the single quotes. As a result, we have to escape every backslash twice!
    #   net use /user:"xxx" \\\\10.0.10.6\\Shared xxx
    
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
        
}

accessNetworkShares