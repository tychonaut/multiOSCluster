#!/bin/bash

#WIP, EXPERIMENTAL

# repository directory is on folder above this script
REPO_DIR="$( readlink -f $( dirname $0 )/.. )"

# recursive, compress during transfer, human readable, verbose, show progress, -e: specify rmote shell (ssh)

# target dir must omit the last folder name
targetDir="$( readlink -f ${REPO_DIR}/.. )"

# don't sync files with names read from the following file
rsyncignoreFileName="${REPO_DIR}/manage/.rsyncignore"

rsync --dry-run  -r -z  -h -v --progress --exclude-from="${rsyncignoreFileName}" -e "ssh -i ~/.ssh/id_rsa" "${REPO_DIR}"  ARENART1+arena@arenart1:"${targetDir}"



    # --exclude=PATTERN       exclude files matching PATTERN
    # --exclude-from=FILE     read exclude patterns from FILE
    # --include=PATTERN       don't exclude files matching PATTERN
    # --include-from=FILE     read include patterns from FILE
    # --files-from=FILE       read list of source-file names from FILE

