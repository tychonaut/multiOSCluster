#!/bin/bash

# repository directory is one folder above this script's location
REPO_DIRECTORY="$( readlink -f $( dirname $0 )/.. )"


###############################################################################
# help
usage()
{
    echo \
"Usage syntax: $0 
    [-h|--help] 
    [ [-a|--all] | [-m|--master|--masters]  [-s|--slaves] ] 
    [--ignorefile <ignore file path>]
    --source-path <source file path>

Copies files/folder contents given in <source file path> to all cluster nodes indicated via the flags (-a|-m|-s).
Rsync is used, which inturn uses ssh. Target path is the same as the source path.
Files in <source file path> that match the patterns in <ignore file path>] are ignored.
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
sourcePath=""

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


# target dir must omit the last folder name
targetDir="$( readlink -f ${REPO_DIRECTORY}/.. )"




hostsFilePath="${REPO_DIRECTORY}/config/hosts.json"
sshStrings=( $(  ${REPO_DIRECTORY}/helpers/createSSHstringsFromJSON.sh "${hostsFilePath}" "${useMasters}" "${useSlaves}" ) )

for index in ${!sshStrings[@]}; do

    currentSSHString="${sshStrings[${index}]}"
    currentHostname="${currentSSHString##*@}"
    #scriptFileExtension="${scriptFileName##*.}"
    
    if [[ $(hostname) != "${currentHostname}" ]]; then
    
        #--dry-run
    
        rsync -r -z  -h -v --progress "${ignoreString}" -e "ssh -i ~/.ssh/id_rsa" "${sourcePath}"  "${sshStrings[${index}]}":"${targetDir}"
        
    else
        echo "Rsyncing: skipping host $(hostname) to omit self-targeting"
        sleep 3
    fi

done
