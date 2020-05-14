#!/bin/sh


# repository directory is one folder above this script's location
REPO_DIRECTORY="$( readlink -f $( dirname $0 )/.. )"



hostsFilePath="${REPO_DIRECTORY}/config/hosts.json"
credentialsFilePath="${REPO_DIRECTORY}/config/credentials.json"


###############################################################################
#
usage()
{
    echo \
"Usage syntax: $0 
    [-h|--help] 
    [ [-a|--all] | [-m|--master|--masters]  [-s|--slaves] ] 
    [-NAS|--need-shared-folder-access] 
    [ --execute-script  <scriptPath>  [ --args  <arg list to script> ] ]
    [ -c|--execute-command <command> ]
    [ -scp|--transfer-file <filePath>  [ --remote-dir  <remote directory> ] ]

Usage example: Script mode: 
    $0 --execute-script ./testScript1.sh --args argtoTestScript1 argtoTestScript2
    Test NAS access with both bash and powershell scripts:
    $0 -a -NAS --execute-script /d/devel/scripts/multiOSCluster/helpers/testScript1.ps1 --args leal lol
    $0 -a -NAS --execute-script /d/devel/scripts/multiOSCluster/helpers/testScript1.sh  --args leal lol
Usage examples: Command mode: 
    List directory /d/devel/ on each machine:
    $0 --execute-command \"ls -la /d/devel/\"
    Install rsync on each machine:
    $0 -a -c \"pacman -S --noconfirm rsync\"
    Install jq on each machine:
    $0 -a -c \"pacman -S --noconfirm mingw-w64-x86_64-jq\"
    $0 -a -c \"pacman -S --noconfirm mingw-w64-x86_64-winpthreads-git\"

Usage examples: File transfer mode: 
    $0 --transfer-file config.cfg --remote-dir /d/apps/myApp/config/
    To distribute your .bashrc:
    $0 -scp ~/.bashrc --remote-dir "~"

Description: Script mode:
    This script executes the script *contents* of the 'payload script' <scriptPath> 
    on each machine specified in ${hostsFilePath} with the parameters following the '--args'.
    Note the implication that only scripts work that do not rely on their own filename 
    or a specific working directory! Contents will be executed in the remote's 'home' directory,
    i.e. /home/<username>/ on Linux and  C:\\msys64\\home\\<username> on Windows!
    
Description: Command mode:
    Similar to script mode, except a single command is directly passed and executed
    
Description: File transfer mode:
    Performs a recursive (i.e. whole folders can be copied) scp file transfer of given
    file path to the remote machines. If a remote directory is specified 
    (--remote-dir), the file will be stored on the remote at that directory 
    (which must exist). Otherwise, it will be stored on the remote 
    at the same directory as on the sending machine (which also must exists).
    WARNING: Be careful with file transfers from or to  the home environment (~/):
    This spripts expands relative paths to absolute path, in which the username is made explicit.
    This may result in problems if local an remote user are different.
    If in doubt, provide the remot dir explicitly (e.g. --remote-dir \"~\")

The default behaviour is to perform actions on all cluster nodes 
specified in ${hostsFilePath}, including master(s) (option '-a').
Note 1: In principle, there could be several master machines, 
        though a single machine is most common.
Note 2: If a shared folder like a NAS must be accessed for successful completion
        of the action, provide the --need-shared-folder-access flag.
        Reason: Windows has a policy to prohibit access to network shares 
        in admin mode. The remote shells run in admin mode.
        Hence the network shares must be explicitly mapped and authenticated 
        via the credentials in ${credentialsFilePath} (\"NAS\" entry)
"
}



###############################################################################
# parse args
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

# which node type to perform stuff on?
useMasters=0
useSlaves=0
nodeTypeSelectionFound=0

#"script", "command" or "scp"
actionMode=""
accessSharedFolders=0

# variables for script execution mode
scriptPath=""
scriptArgs=""

# variables for direct command execution mode
command=""


# variables for file transfer mode
filePathToTransfer=""
remoteDirectory=""


while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
    
        -h|--help)
            usage
            exit 0
        shift # past argument
        ;;
        
        -a|--all)
            shift # past argument
            useMasters=1
            useSlaves=1
            nodeTypeSelectionFound=1
        ;;
        -m|--master|--masters)
            shift # past argument
            useMasters=1
            nodeTypeSelectionFound=1
        ;;
        -s|--slaves)
            shift # past argument
            useSlaves=1
            nodeTypeSelectionFound=1
        ;;
        
    
        --execute-script)
            shift # past argument
            scriptPath="${1}"
            shift # past value
            if [[ ${actionMode} != "" ]]; then
                echo "error: only one action mode is allowed per script execution"
                usage
                exit 1
            fi 
            actionMode="script"
        ;;
        
        --args)
            shift # past argument
            if [[ ${actionMode} != "script" ]]; then
                echo "error: ${key} option only valid for script execution mode! "
                usage
                exit 1
            fi 
            scriptArgs="${@}"
            # no further parsing here, rest is for "payload script"
            break
        ;;
        
    
        -c|--execute-command)
        
            shift # past argument
            command="${1}"
            shift # past value
            
            if [[ ${actionMode} != "" ]]; then
                echo "error: only one action mode is allowed per script execution"
                usage
                exit 1
            fi 
            actionMode="command"
        ;;
        
        -scp|--transfer-file)
            shift # past argument
            filePathToTransfer="${1}"
            shift # past value
            
            if [[ ${actionMode} != "" ]]; then
                echo "error: only one action mode is allowed per script execution"
                usage
                exit 1
            fi 
            actionMode="scp"
        ;;
        
        --remote-dir)
            shift # past argument
            remoteDirectory="${1}"
            shift # past value
            
            if [[ ${actionMode} != "scp" ]]; then
                echo "error: ${key} option only valid for file transfer mode! "
                usage
                exit 1
            fi 

        ;;
        
        -NAS|--need-shared-folder-access)
            shift # past argument
            accessSharedFolders=1
        ;;
    
        *)    # unknown param,  implies incorrect use here
            echo "error: invalid param: ${key}"
            usage
            exit 1
            #POSITIONAL+=("$1") # save it in an array for later
            #shift # past argument
        ;;
    esac
done
#set -- "${POSITIONAL[@]}" # restore positional parameters to this script, i.e. $@

if [[ ${nodeTypeSelectionFound} == 0 ]]; then
    #default: use all node types
    useMasters=1
    useSlaves=1
fi

accessSharedFoldersCommand=""
if [[ ${accessSharedFolders} == 1 ]]; then
    accessSharedFoldersCommand="${REPO_DIRECTORY}/helpers/accessNetworkShares.sh"
fi



###############################################################################
# do the remote execution via SSH




sshStrings=( $(  ${REPO_DIRECTORY}/helpers/createSSHstringsFromJSON.sh "${hostsFilePath}" "${useMasters}" "${useSlaves}" ) )

for index in ${!sshStrings[@]}; do

    #--------------------------------------------------------------------------
    if   [[ "${actionMode}" == "script" ]]; then
    
        if [[ ${scriptPath} == "" ]]; then
            echo "error: no script path provided"
            exit 1
        fi

        scriptFileName="${scriptPath##*/}"
        scriptFileExtension="${scriptFileName##*.}"
        #scriptFileNameWoExtension="${scrip tFileName%.*}"

        scriptContents=$(cat ${scriptPath})

        echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        echo "ssh-ing to "${sshStrings[${index}]}" with in-place-execution of script contents:"
        
        if   [[ "${scriptFileExtension}" == "sh" ]]; then
        
            # It's a (ba)sh script; execute contents in-place after args are passed via "set -- "
            

            ssh "${sshStrings[${index}]}" <<-ENDSSH
                set -- "${scriptArgs[@]}" 
                ${accessSharedFoldersCommand}
                ${scriptContents}
ENDSSH
            
        elif [[ "${scriptFileExtension}" == "ps1" ]]; then
        
            # It's a powershell script; special treatment in order to make param passing work:
            # scp the payload script to a temporary remote script file.

            scp "${scriptPath}" "${sshStrings[${index}]}":temporaryScript.ps1

            # Then ssh into remote with the following 3-line inline code:
            ssh "${sshStrings[${index}]}" <<-ENDSSH
                set -- "${scriptArgs[@]}"
                ${accessSharedFoldersCommand}
                powershell –ExecutionPolicy Bypass ./temporaryScript.ps1 $@
                rm ./temporaryScript.ps1
ENDSSH

        else
            echo "script file extension type not yet supported: ${scriptFileExtension}"
            exit 1
        fi
        
        echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
        echo
        
    #--------------------------------------------------------------------------
    elif [[ "${actionMode}" == "command" ]]; then
        
        if [[ ${accessSharedFolders} == 1 ]]; then
            ssh "${sshStrings[${index}]}" "${accessSharedFoldersCommand};  ${command}" &
        else
            ssh "${sshStrings[${index}]}" "${command}" &
        fi
    

    #--------------------------------------------------------------------------
    elif [[ "${actionMode}" == "scp" ]]; then
        
        #TODO find a way to enable NAS access if definitely neeeded:
        # complicated but should work: scp source files to temp. local directory on target machine,
        # then ssh into target machine, exec. NAS access script, copy local files to final NAS directory, finally delet local copy.

        
        fileNameToTransfer="${filePathToTransfer##*/}"
        
        #echo "fileNameToTransfer: $fileNameToTransfer"
        #echo "${remoteDirectory}/${fileNameToTransfer}"
        
        if [[ "${remoteDirectory}" != "" ]]; then
            scp "${filePathToTransfer}" "${sshStrings[${index}]}":"${remoteDirectory}/${fileNameToTransfer}"
        else
            #scp "${filePathToTransfer}" "${sshStrings[${index}]}":"${fileNameToTransfer}"
            fullFilePathToTransfer=$( readlink -f "${filePathToTransfer}" )
            scp -r "${filePathToTransfer}" "${sshStrings[${index}]}":"${fullFilePathToTransfer}"
        fi
        
    else 
        echo "fatal internal logical error"
        exit 2
    fi
    
done
#--------------------------

echo "done performing action \"${actionMode}\" on selected cluster machines"
exit 0
