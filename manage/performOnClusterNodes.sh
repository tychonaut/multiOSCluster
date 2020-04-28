#!/bin/sh

echo
echo "TODOS --------------------------------------------------"
echo "TODO 1: convert relative to absolute path in scp mode"
echo "TODO 2: develop network share enable mechanism for botch bash and powershell"
echo "--------------------------------------------------------"
echo

REPO_DIR="/d/devel/scripts/multiOSCluster"
hostsFilePath="${REPO_DIR}/config/hosts.json"
credentialsFilePath="${REPO_DIR}/config/credentials.json"


###############################################################################
#
usage()
{
    echo \
"Usage syntax: $0 
    [-h|--help] 
    [ [-a|--all] | [-m|--master|--masters]  [-s|--slaves] ] 
    [--need-shared-folder-access] 
    [ --execute-script <scriptPath>  [ --args  <arg list to script> ] ]
    [ --execute-command <command> ]
    [ --transfer-file <filePath>  [ --remote-dir  <remote directory> ] ]

Usage example: Script mode: 
    $0 --execute-script ./testScript1.sh --args argtoTestScript1 argtoTestScript2
Usage example: Command mode: 
    $0 --execute-command \"ls -la\"
Usage example: File transfer mode: 
    $0 --transfer-file config.cfg --remote-dir /d/apps/myApp/config/

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
fileToTransfer=""
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
                exit 1
            fi 
            actionMode="script"
        ;;
        
        --args)
            shift # past argument
            if [[ ${actionMode} != "script" ]]; then
                echo "error: ${key} option only valid for script execution mode! "
                exit 1
            fi 
            scriptArgs="${@}"
            # no further parsing here, rest is for "payload script"
            break
        ;;
        
    
        --execute-command)
            shift # past argument
            command="${1}"
            shift # past value
            
            if [[ ${actionMode} != "" ]]; then
                echo "error: only one action mode is allowed per script execution"
                exit 1
            fi 
            actionMode="command"
        ;;
        
        --transfer-file)
            shift # past argument
            fileToTransfer="${1}"
            shift # past value
            
            if [[ ${actionMode} != "" ]]; then
                echo "error: only one action mode is allowed per script execution"
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
                exit 1
            fi 

        ;;
        
        --need-shared-folder-access)
            shift # past argument
            accessSharedFolders=1
        ;;
    
        *)    # unknown param,  implies incorrect use here
            usage
            exit 0
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


if [[ ${scriptPath} == "" ]]; then
    echo "error: no script path provided"
    exit 1
fi






###############################################################################
# do the remote execution via SSH


##-----------------------------------
## approach 1: copy script, then execute; gets complicated if target directory does not exist, also pollutes remote machine

#for index in ${!sshStrings[@]}; do
#   echo "scp-ing ${scriptPath} to "${sshStrings[${index}]}" ..."
#   scp "${scriptPath}" "${sshStrings[${index}]}":"${scriptPath}"   
#       
#   echo "ssh-ing to "${sshStrings[${index}]}" ..."
#   ssh "${sshStrings[${index}]}" "${scriptPath} ${scriptArgs}"
#done
##-----------------------------------



#-----------------------------------
# approach 2: execute script in-place (at least for bash )


scriptFileName="${scriptPath##*/}"
scriptFileExtension="${scriptFileName##*.}"
#scriptFileNameWoExtension="${scriptFileName%.*}"


scriptContents=$(cat ${scriptPath})

sshStrings=( $(  ${REPO_DIR}/helpers/createSSHstringsFromJSON.sh "${hostsFilePath}" "${useMasters}" "${useSlaves}" ) )

for index in ${!sshStrings[@]}; do

    if   [[ "${actionMode}" == "script" ]]; then

        echo "ssh-ing to "${sshStrings[${index}]}" with in-place-execution of script contents:"
        
        if   [[ "${scriptFileExtension}" == "sh" ]]; then
        
            # It's a (ba)sh script; execute contents in-place after args are passed via "set -- "
            
            ssh "${sshStrings[${index}]}" <<-ENDSSH
                set -- "${scriptArgs[@]}" 
                ${scriptContents}
            ENDSSH
            
        elif [[ "${scriptFileExtension}" == "ps1" ]]; then
        
            # It's a powershell script; special treatment in order to make param passing work:
            # scp the payload script to a temporary remote script file.

            scp "${scriptPath}" "${sshStrings[${index}]}":temporaryScript.ps1

            # Then ssh into remote with the following 3-line inline code:
            ssh "${sshStrings[${index}]}" <<-ENDSSH
                set -- "${scriptArgs[@]}"
                powershell –ExecutionPolicy Bypass ./temporaryScript.ps1 $@
                rm ./temporaryScript.ps1
            ENDSSH

        else
            echo "script file extension type not yet supported: ${scriptFileExtension}"
            exit 1
        fi
        
        
        
    fi
    
done
#--------------------------

echo "done scp and/or ssh"
exit 0
