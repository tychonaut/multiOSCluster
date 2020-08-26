#!/bin/bash

# ------------------------------------------------------------------------------------------------ #
#                                This file is part of CosmoScout VR                                #
#       and may be used under the terms of the MIT license. See the LICENSE file for details.      #
#                         Copyright: (c) 2019 German Aerospace Center (DLR)                        #
# ------------------------------------------------------------------------------------------------ #

# ------------------------------------------------------------------------------
# usage: ./launch_on_powerwall.sh [launcher, master, client] [display system]
#
# This script has to be executed on the powerwall master (currently SC-010106L).
# The first parameter defines the role which defaults to "launcher"
#  * launcher: Executes this script five times, launching four clients
#              and the master (default option)
#  * master:   Starts $EXECUTABLE in master mode
#  * client:   Starts $EXECUTABLE in client mode. The second parameter defines
#              which display system is to be used.
# ------------------------------------------------------------------------------

# change this according to your application
EXECUTABLE=cosmoscout

# scene config file can be passed as first parameter
SETTINGS="${1:-../share/config/full_vrlab.json}"

# vista ini can be passed as third parameter
VISTA_INI="${2:-vista_powerwall.ini}"

# the role is passed automatically as third parameter
# if no argument is given, launcher is assumed
ROLE="${3:-launcher}"

# get the directory and name of this script
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
SCRIPT_NAME="$( basename "$0" )"

# load the required modules ----------------------------------------------------
module() { eval `/usr/bin/modulecmd bash $*`; }
export MODULEPATH=/tools/modulesystem/modulefiles

module purge
module load iv-group/ubuntu18.04/release

export LD_LIBRARY_PATH=../lib:$LD_LIBRARY_PATH

function kill_old_processes() {
    echo "Killing old processes..."

    ssh SC-010105L "(killall -9 $EXECUTABLE)" &> /dev/null

    ssh SC-010102L "(killall -9 $EXECUTABLE)" &> /dev/null
    ssh SC-010103L "(killall -9 $EXECUTABLE)" &> /dev/null
    ssh SC-010104L "(killall -9 $EXECUTABLE)" &> /dev/null
}

function handle_ctrl_c() {
    echo "Caught Ctrl-C"
    kill_old_processes
    echo "Bye!"
    exit 0
}

# launcher mode ----------------------------------------------------------------
if [ "$ROLE" == "launcher" ]
then
    echo "Launching clients..."

    trap handle_ctrl_c INT

    ssh SC-010102L "(\"$SCRIPT_DIR/$SCRIPT_NAME\" $SETTINGS $VISTA_INI client LEFT   DLR-SLAVE-1 &> \"$SCRIPT_DIR/powerwall_l.log\";)" &
    ssh SC-010103L "(\"$SCRIPT_DIR/$SCRIPT_NAME\" $SETTINGS $VISTA_INI client MIDDLE DLR-SLAVE-2 &> \"$SCRIPT_DIR/powerwall_m.log\";)" &
    ssh SC-010104L "(\"$SCRIPT_DIR/$SCRIPT_NAME\" $SETTINGS $VISTA_INI client RIGHT  DLR-SLAVE-3 &> \"$SCRIPT_DIR/powerwall_r.log\";)" &

    sleep 5

    echo "Launching master..."

    # wait
    ssh SC-010105L "(\"$SCRIPT_DIR/$SCRIPT_NAME\" $SETTINGS $VISTA_INI master)" &

    # wait for keyboard input ------------------------------------------------------
    read

    kill_old_processes

    echo "Fare well!"

# master mode ------------------------------------------------------------------
elif [ "$ROLE" == "master" ]
then

    cd "$SCRIPT_DIR"
    DISPLAY=:0.0 ./$EXECUTABLE --settings=$SETTINGS -vistaini $VISTA_INI -newclustermaster MASTER

# client mode ------------------------------------------------------------------
elif [ "$ROLE" == "client" ]
then

    cd "$SCRIPT_DIR"
    DISPLAY=:0.0 ./$EXECUTABLE --settings=$SETTINGS -vistaini $VISTA_INI -newclusterslave $4

fi
