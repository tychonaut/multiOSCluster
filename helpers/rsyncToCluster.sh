#!/bin/bash



###############################################################################
# help
usage()
{
    echo \
"Usage syntax: $0 
    [--dry-run]
    [-h|--help] 
    [ [-a|--all] | [-m|--master|--masters]  [-s|--slaves] ] 
    [--ignorefile <ignore file path>]
    --source-path <source file path on local machine>
    --target-dir <target directory on remote machine>

Copies files/folder contents given in <source file path> to all cluster nodes indicated via the flags (-a|-m|-s).
Rsync is used, which inturn uses ssh. Target path is the same as the source path.
Files in <source file path> that match the patterns in <ignore file path>] are ignored.
'--dry-run' will execute a dry run, i.e. not change remote files.

Self-targeting (e.g. from and to a master node) is handled gracefully, either by omission or by local (non-ssh) rsyncing.
"
}




###############################################################################
# parse args

# which node type to perform stuff on?
useMasters=0
useSlaves=0
nodeTypeSelectionFound=0


rsyncignoreFilePath=""
ignoreString=""
dryRunString=""
sourcePath=""
targetDir=""

while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
    
        -h|--help)
            usage
            exit 0
        shift # past argument
        ;;
        
                
        --dry-run)
            shift # past argument
            dryRunString="--dry-run"
            shift # past value    
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
        
        --ignorefile)
            shift # past argument
            rsyncignoreFilePath="${1}"
            shift # past value
            #TODO check for existence of rsyncignoreFilePath
            ignoreString="--exclude-from=${rsyncignoreFilePath}"
        ;;        
        
        
        --source-path)
            shift # past argument
            sourcePath="${1}"
            shift # past value    
        ;;
        
        --target-dir)
            shift # past argument
            targetDir="${1}"
            shift # past value    
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


if [[ ${sourcePath} == "" ]]; then
    echo "error: no source path given"
    usage
    exit 1
fi

if [[ ${targetDir} == "" ]]; then
    echo "error: no target directory given"
    usage
    exit 1
fi



rsyncToCluster()
{
    local optionFlags="-r -z -h -v --progress"
    if [[ "${dryRunString}" != "" ]]; then
        optionFlags+=" --dry-run"
    fi
    if [[ "${ignoreString}" != "" ]]; then
        optionFlags+=" ${ignoreString}"
    fi

    # repository directory is one folder above this script's location
    local REPO_DIRECTORY="$( readlink -f $( dirname $0 )/.. )"


    local hostsFilePath="${REPO_DIRECTORY}/config/hosts.json"
    local sshStrings=( $(  ${REPO_DIRECTORY}/helpers/createSSHstringsFromJSON.sh "${hostsFilePath}" "${useMasters}" "${useSlaves}" ) )

    for index in ${!sshStrings[@]}; do

        local currentSSHString="${sshStrings[${index}]}"
        local currentHostname="${currentSSHString##*@}"
        #scriptFileExtension="${scriptFileName##*.}"
        
        echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        
        #https://stackoverflow.com/questions/33980224/how-to-check-if-two-paths-are-equal-in-bash
        local parentOfSourceDirExpanded="$( readlink -f ${sourcePath}/.. )"
        local targetDirExpanded="$( readlink -f ${targetDir} )"
        if [[ $(hostname) == "${currentHostname}" ]]; then
        
            if [[ "${parentOfSourceDirExpanded}" -ef  "${targetDirExpanded}"  ]]; then
        
                echo "Rsyncing: skipping host $(hostname) to omit self-targeting, as both source and target machines and paths are equal"
                sleep 1
                
            else
                
                 echo "Rsyncing: host $(hostname) is both source and target, performing rsync locally instead of via SSH:"
				 echo "sourcePath: ${sourcePath}"
                 sleep 1
                
                #--include=*
                rsync $optionFlags "${sourcePath}" "${targetDir}"
                
            fi
            
            sleep 3
            
        else
            echo "rsync-ing path \"${sourcePath}\" to "${sshStrings[${index}]}" at remote  directory ${targetDir} :"
        
            # recursive, compress during transfer, human readable, verbose, show progress, -e: specify remote shell (ssh)
       
            #--include=*
            echo "optionFlags:${optionFlags}"
            rsync $optionFlags  -e "ssh -i ~/.ssh/id_rsa" "${sourcePath}" "${sshStrings[${index}]}":"${targetDir}"
        fi

        echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
        echo
    done

}

rsyncToCluster $@