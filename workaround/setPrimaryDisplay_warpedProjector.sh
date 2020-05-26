#!/bin/bash 

#wrap code into function in order to not clutter variable space with global variables,
# as this can make nested script calls malfunction
funcWrapper()
{
    local SCRIPT_DIRECTORY="$( readlink -f $( dirname $0 ))"
    ${SCRIPT_DIRECTORY}/setPrimaryDisplay.sh warpedProjector $@
}

#invoke
funcWrapper $@
