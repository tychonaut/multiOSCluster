# multiOSCluster

This is a collection of scripts to manage and use a cluster of computers that are supposed 
to run multiple applications on both Windows and Linux.
	
This both increases productivity during development and improves user experience for the end user
(e.g. a scientist using a visualization application in a dome).

The technological backbone is comprised of SSH, bash and rsync. 
Where needed and not easily implemented via bash on Windows, powershell is used instead.
To enable this workflow on Windows, msys2's sshd is used.

### Main features:
1. Efficiently sync files from a development or master computer to the cluster.
2. Fast deployment, configuration and launch of applications:
	* Streamlined deployment for fast iteration cycles: 
	  programming -> compiling -> local installing -> rsync updates to cluster -> launching on cluster
	* Centralized app configuration via named profiles, distributed via rsync if needed
	* Easy launch of applications: One call to a launch script from command line or double click on a shortcut
3. Rebooting the cluster to Windows and Linux, i.e. change the operating system the cluster is running.
   (WIP: scripts are written and tested on a single machine, yet not on a cluster, 
   as we haven't even installed Linux on the cluster machines yet.)




### Consider before usage: 

This collection of scripts is written with general and cross-plattform-applicability in mind, in order to be helpful for those facing similar problems.
But please be aware of the following facts upon evaluation:

* Despite the above goals, so far, it is only used in a specific visualization dome, 
  the [ARENA2 at GEOMAR, Kiel](https://www.geomar.de/en/research/fb4/fb4-muhs/infrastructure/arena/).
  Hence it  contains a lot of code and especially config files specific to ARENA2.	  
* This repository is just a by-product of application software development, hence don't expect too much polish.
* This repo is heavy work in progress, hence incomplete and  partially untested
  (Especially the the cross-plattform-applicability and the reboot/multiboot part,
  as we don't even have installed Linux on our cluster yet!).
	
Feel free to contact me if you are interested in using this repo.

## Applications maintained:

* [OpenSpace](https://www.openspaceproject.com)
* [ParaView](https://www.paraview.org/Wiki/ParaView/VRPN_with_MS-MPI) (WIP)
* [Google Earth / Liquid Galaxy](https://liquidgalaxy.org) (WIP)
  This closed-source application has two minor, 
  but very annoying issues, that could easily fixed by Google, but haven't for about 10 years now.
  This makes it basically impossible to use Google Earth in a dome *not* as continuously running installation, 
  but as one app among many:
	1. It cannot go completely fullscreen; Ther is always a horizontal bar at the top of each window.
	   This is particularly annoying as it messes up the aspect ratio
	2. Furthermore It can only be killed by force, 
	   often causing a prompt for launching a repair tool upon restart, prohibiting automated restart.
* [CosmoScout](https://github.com/cosmoscout/cosmoscout-vr) (planned)
* [KeckCaves](http://keckcaves.org/about/start) (considered)
* [Unreal Engine 4 via nDisplay](https://docs.unrealengine.com/en-US/Engine/Rendering/nDisplay/index.html) (considered)
		
	


## Dependencies:

On each involved computer, the following software must be installed:

* Windows:
	* [msys2](https://www.msys2.org/)
		Enables Linux-like environment including bash and SSH
	* [PStools](https://docs.microsoft.com/en-us/sysinternals/downloads/pstools)
		Allows launching GUI apps and network accesson remote machines

* On all platforms:
	*TODO extract from setup protocol (all stuff from package manager)
	


## Setup, config & deploy the scripts

TODO transform setup protocol to more readable instructions. 
Until then, you must crawl through the [dumpy setup protocol](https://github.com/tychonaut/multiOSCluster/blob/master/doc/setup_protocol_msys_sshd.txt)

* Install the dependencies above on all involved computers
  (TODO refine: setup sshd, trusted hosts etc)
		
* Enter all hosts that are part of the cluster into
  <multiOsCluster directory>/config/hosts.json
	
* To make sure the scripting logic operates correctly, the repo content must reside on each cluster node
  an in the same root directory.
  (Albeit in fact not required for most of the logic, sometimes there may be remote calls to local scripts 
  that are expected to exist and be up-to-date.)

* The repo can distribute itself to all nodes in <multiOsCluster directory>/config/hosts.json by running
  `<multiOsCluster directory>/manage/rsyncWholeScriptRepoToCluster.sh`.
  Perform this step after each change to the scripts themselves.
	   

## file copy & snyc

There is an scp-wrapper:
	
E.g run `<multiOsCluster directory>/manage/performOnClusterNodes.sh 
	--transfer-file /my/local/asset/directory/ --remote-dir /remote/asset/directory/`

TODO check functionality and elaborate
	
	


## application deploy, config & launch

### app deploy

If your application development profits from minimizing time between 
doing a source code change an seeing the change reflected in the cluster running the modified app, 
consider the following workflow:

1. On your developer machine, create a local installation in a directory 
   <app install dir> of a cluster-enabled app that can run by just being copied, 
   i.e. no convoluted installer involved and all dependencies met on all target machines.
2. For the application <app name>, create an entry in 
   `<multiOsCluster directory>/config/apps.json : ".apps.<operating system>.<app name>"`,
   with the following contents: 
    * "installDir": Local installation directory on all cluster nodes, has to be the same directory as on the developer machine.
    * "executable": Path of executable, relative to "installDir"
3. After a programming change you want to test on the cluster:
    1. Compile the app.
    2. Local-install the app to the development machine at `<app install dir>`.
3. Files that shall *not* be synced to the cluster can be specified in 
   `<multiOsCluster directory>/appControl/<app name>/sync/rsyncignore_install'
4. Rsync the files by calling `<multiOsCluster directory>/appControl/rsyncAppInstallDirToCluster.sh <app name>`
	   

### app config 

There are a lot of distributed apps that need certain files avaiable locally on each node before launch.
In order to be able to easily update and switch configurations with those applications,
you can send relevant config/calibration/asset/whatever files to each dome node as follows:

1. Specify a "profile" entry in `<multiOsCluster directory>/config/apps.json : ".apps.<operating system>.<app name>"`:
   `"profile" : "<profile name>"`
2. This entry rsync's the folder contents from
   `<multiOsCluster directory>/appControl/<app name>/profiles/<profile name>`
   to the installation directory  of `<app name>` ("installDir" entry in apps.json)
   upon calling 
   `<multiOsCluster directory>/appControl/rsyncAppConfigToCluster.sh <app name>`.
   
#### Example: ParaView:

In order to easily configure ParaView to run in a CAVE-like setup, we have the following four files in our 
"default" profile (`<multiOsCluster directory>/appControl/ParaView/profiles/default`):

1. `dome_arena.pvx` : Specifies for each cluster node the display parameters and the virtual frustum
2. `default_servers.pvsc`: Specifies connection parameters for a ParaViewClient to a ParaView server (pvserver).
   Our name for the server is "arenaCluster".
3. `launchClusterServers.ps1`: pvserver is an [MPI](https://en.wikipedia.org/wiki/Message_Passing_Interface) program.
   On each render computer, one instance needs to be launched. Albeit just a single command, it is a long one,
   and for future generalization, we have outsourced it to launch `launchClusterServers.ps1` powershell script. 
4. `machines.txt`: Contains the host names to launch pvserver instances in. Read by `mpiexec.exe`

Although technically, only `dome_arena.pvx` is needed on each cluster node, to keep things simple, we sync all of the files to each node. Rsync is pretty efficient in finding out which files don't need updating, so the overhead is neglegible.

### app launch

Launching and shutting down apps has most diversity among distributed apps, so there is no general rule.
Here are some examples:

#### Example: ParaView:
While rather complicated to set up and configure for clustered operation, it is is pretty easy to launch afterwards:
`paraview --server=arenaCluster`.
If the launching shall depend on the "installDir" and "executable" entries of "apps.json", this could be put into a simple script:

TODO write and test script, document here.

#### Example: OpenSpace:
Unfortunately, there is no way to elegantly launch OpenSpace on each cluster node.
On Linux, this is not a major problem, as you can launch a GUI app from a remote ssh session e.g. via the "DISPLAY=0" environment variable.
On Windows, this is much more complicated: The remote SSH session prohibits showing the graphical part of a remotely launched app,
*and* it prohibits network access for remotely launched apps!
The issue can be workarounded via [PStools](https://docs.microsoft.com/en-us/sysinternals/downloads/pstools).
It has some inconsitent usages and seems to interfere with Windows' NAS mappings upon reboot, hence this is not the most desirable solution.
The admittedly pretty complicated result is found and executable in 
`<multiOSCluster dir>/appControl/OpenSpace/launch/cluster/launchOpenSpaceOnCluster.sh`

We are currently working on a small "launch app xy"-deamon for Windows to resolve these issues.


		


## Cluster reboot / switching of OS

TODO install Linux on cluster nodes
TODO update and test scripts
TODO update of this section

There seems no simple solution for "multi-booting a computer cluster" around yet, 
but our scientific visualization dome needs this functionality. 

General workflow for booting of the cluster into a different OS:

The master computer logs into the cluster nodes via SSH with admin/super user priviledges.
SSH is provieded either natively for Linux machines, or via MSYS2 on Windows.
Manual input of user credentials are omitted via private/public keys an mutual registration of the public keys as trusted parties.

Once logged in, local native scripts are executed that 
1. Alter the EFI settings boot into the desired OS on next reboot
2. perform the reboot.

On Linux, this is a trivial two-liner.
On Windows, it is way more complicated and currently realized as a combination of self-elevating powershell script which uses a python script for easier string manipulation.
