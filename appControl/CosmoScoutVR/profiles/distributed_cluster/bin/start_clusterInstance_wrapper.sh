#!/bin/bash

# ------------------------------------------------------------------------------------------------ #
#                                This file is part of CosmoScout VR                                #
#       and may be used under the terms of the MIT license. See the LICENSE file for details.      #
#                         Copyright: (c) 2019 German Aerospace Center (DLR)                        #
# ------------------------------------------------------------------------------------------------ #

# ------------------------------------------------------------------------------
# usage: ./launch_on_displaywall.sh [launcher, master, client] [display system]
#
# This script has to be executed on the displaywall master (currently
# SC-010081L). The first parameter defines the role which defaults to "launcher"
#  * launcher: Executes this script six times, launching five clients
#              and the master (default option)
#  * master:   Starts $EXECUTABLE in master mode
#  * client:   Starts $EXECUTABLE in client mode. The second parameter defines
#              which display system is to be used.
# ------------------------------------------------------------------------------


# change this according to your application
#EXECUTABLE=cosmoscout
#EXECUTABLE=cosmoscout.exe
EXECUTABLE=start_clusterInstance.bat

# scene config file can be passed as first parameter
#SETTINGS="${1:-../share/config/local_cluster.json}"
# above does not work
SETTINGS="${1:-../share/config/simple_desktop_and_cluster.json}"

# vista ini can be passed as second parameter
VISTA_INI="${2:-vista_distributed_cluster.ini}"

# the role is passed automatically as third parameter
# if no argument is given, launcher is assumed
ROLE="${3:-launcher}"

# get the directory and name of this script
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
echo "script dir : ${SCRIPT_DIR}"
SCRIPT_NAME="$( basename "$0" )"
echo "script name : ${SCRIPT_NAME}"

# Set paths so that all libraries are found.
export LD_LIBRARY_PATH=../lib:../lib/DriverPlugins:$LD_LIBRARY_PATH
export VISTACORELIBS_DRIVER_PLUGIN_DIRS=../lib/DriverPlugins

export PATH=${SCRIPT_DIR}/../lib/DriverPlugins:$PATH


if [ $(hostname) == "arenamaster" ]
then
    cd $SCRIPT_DIR
    # Linux:
    #./$EXECUTABLE --settings=$SETTINGS -vistaini $VISTA_INI -newclustermaster MASTER
    # Windows:
    #powershell.exe "./${EXECUTABLE} --settings=${SETTINGS} -vistaini ${VISTA_INI} -newclustermaster MASTER"
    cmd //c ".\\${EXECUTABLE} ${SETTINGS} ${VISTA_INI} -newclustermaster MASTER"
	
else # slaves

    cd $SCRIPT_DIR
    # Linux:
    #./$EXECUTABLE --settings=$SETTINGS -vistaini $VISTA_INI -newclusterslave $4
    # Windows:
    #powershell.exe "./${EXECUTABLE} --settings=${SETTINGS} -vistaini ${VISTA_INI} -newclusterslave $4"
	#local finalCmdCommand=".\\${EXECUTABLE} ${SETTINGS} ${VISTA_INI} -newclusterslave ${4}"
    cmd //c ".\\${EXECUTABLE} ${SETTINGS} ${VISTA_INI} -newclusterslave $(hostname)"
	
fi
# required?
#logout

exit 0


# REST BELOW IS OBSOLETE, TODO REMOVE when sure ----------------------------------------------------------------



# launcher mode ----------------------------------------------------------------
if [ "$ROLE" == "launcher" ]
then

    echo "Launching clients..."

    $SCRIPT_DIR/$SCRIPT_NAME $SETTINGS $VISTA_INI client TOP_LEFT     &> $SCRIPT_DIR/local_cluster_top_left.log &
    $SCRIPT_DIR/$SCRIPT_NAME $SETTINGS $VISTA_INI client TOP_RIGHT    &> $SCRIPT_DIR/local_cluster_top_right.log &
    $SCRIPT_DIR/$SCRIPT_NAME $SETTINGS $VISTA_INI client BOTTOM_LEFT  &> $SCRIPT_DIR/local_cluster_bottom_left.log &
    $SCRIPT_DIR/$SCRIPT_NAME $SETTINGS $VISTA_INI client BOTTOM_RIGHT &> $SCRIPT_DIR/local_cluster_bottom_right.log &

    #sleep 5
    sleep 2

    echo "Launching master..."

    
    # $SCRIPT_DIR/$SCRIPT_NAME $SETTINGS $VISTA_INI master
    ${SCRIPT_DIR}/${SCRIPT_NAME} ${SETTINGS} ${VISTA_INI} master
    
    echo "Killing old processes..."

    #Linux
    killall -9 ${EXECUTABLE}

    echo "Fare well!"

# master mode ------------------------------------------------------------------
elif [ "$ROLE" == "master" ]
then

    cd $SCRIPT_DIR
    # Linux:
    #./$EXECUTABLE --settings=$SETTINGS -vistaini $VISTA_INI -newclustermaster MASTER
    # Windows:
    #powershell.exe "./${EXECUTABLE} --settings=${SETTINGS} -vistaini ${VISTA_INI} -newclustermaster MASTER"
    cmd //c ".\\${EXECUTABLE} ${SETTINGS} ${VISTA_INI} -newclustermaster MASTER"

# client mode ------------------------------------------------------------------
elif [ "$ROLE" == "client" ]
then

    cd $SCRIPT_DIR
    # Linux:
    #./$EXECUTABLE --settings=$SETTINGS -vistaini $VISTA_INI -newclusterslave $4
    # Windows:
    #powershell.exe "./${EXECUTABLE} --settings=${SETTINGS} -vistaini ${VISTA_INI} -newclusterslave $4"
	#local finalCmdCommand=".\\${EXECUTABLE} ${SETTINGS} ${VISTA_INI} -newclusterslave ${4}"
    cmd //c ".\\${EXECUTABLE} ${SETTINGS} ${VISTA_INI} -newclusterslave ${4}"
fi
