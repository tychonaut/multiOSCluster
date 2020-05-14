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




### Consider upon evaluation: 

This collection of scripts is written with general and cross-plattform-applicability in mind, in order to be helpful for those facing similar problems.
But please be aware of the following facts upon evaluation:

* Despite the above goals, so far, it is only used in a specific visualization dome, 
  the [ARENA2 at GEOMAR, Kiel](https://www.geomar.de/en/research/fb4/fb4-muhs/infrastructure/arena/).
  Hence it  contains a lot of code and especially config files specific to ARENA2.	  
* This repository is just a by-product of application software development, hence don't expect too much polish.
* This repo is heavy work in progress, hence incomplete and  partially untested
  (Especially the the cross-plattform-applicability and the reboot/multiboot part,
  as we don't even have installed Linux on our cluster yet!).
	


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
	* msys2
		Enables Linux-like environment including bash and SSH
	* PStools (https://docs.microsoft.com/en-us/sysinternals/downloads/pstools)
		Allows launching GUI apps and network accesson remote machines

* On all platforms:
	*TODO extract from setup protocol (all stuff from package manager)
	




## setup, config & deploy the scripts

	TODO transform setup protocol to useable instructions
	
	* install the dependencies above on all involved computers
		(TODO refine: setup sshd, trusted hosts etc)
		
	* Enter all hosts that are part of the cluster into
		<multiOsCluster directory>/config/hosts.json
	
	* To make sure the scripting logic operates correctly, it must reside on each cluster node.
	  (This is in fact not required for most of the logic, but sometimes, there are remote calls to local scripts that are expected to exist and be up-to-date.)
	  It can distribute itself to all nodes in <multiOsCluster directory>/config/hosts.json by running
	  `<multiOsCluster directory>/manage/rsyncWholeScriptRepoToCluster.sh`
	  Perform this step after each change to the scripts themselves.
	   

	
	
	TODO some stuff about Windows, PsExec.exe and NAS access via `net use`

## file copy & snyc

	There is an scp-wrapper 
	
	`<multiOsCluster directory>/manage/performOnClusterNodes.sh --transfer-file /my/local/asset/directory/ --remote-dir /remote/dierectory/`

	TODO write doc
	
	

## application deploy, config & launch

### app deploy

	If your application development profits from minimizing time between 
	doing a source code change an seeing the change reflected in the cluster running the modified app, 
	consider the following workflow:

	1. On your developer machine, create a local installation in a directory <app install dir> of a cluster-enabled app that can run by just being copied, 
	   i.e. no convoluted installer involved and all dependencies met on all target machines
	2. For the application <app name>, create an entry in <multiOsCluster directory>/config/apps.json:
	   ".apps.<operating system>.<app name>"
	   with the following contents: 
	   * "installDir": Local installation directory on all cluster nodes, has to be the same directory as on the developer machine.
	   * "executable": Path of executable, relative to "installDir"
	3. After a programming change you want to test on the cluster:
		1. Compile the app.
		2. Local-install the app to the development machine at <app install dir>.
		3. Files that shall *not* be synced to the cluster can be specified in 
		    <multiOsCluster directory>/appControl/<app name>/sync/rsyncignore_install
		4. Rsync the files by calling ` <multiOsCluster directory>/appControl/rsyncAppInstallDirToCluster.sh <app name>`
	   

### app config 

	In order to be able to easily update and switch dome configurations, 
	you can send relevant config files to each dome node as follows.
	
		   
This entry contains a "profile" entry that is considered to be active for sync'ing config files and launching the app.
Furthermore, an installation directory entry () and the realtive path to the main executable.

	

### app launch


TODO refine doc

		
	
	





 rsync'ing the configuration files for <app name> to the dome

The contents of *one* of the folders folders will be sent to each node of the executables-folder of the installation directory of the application.

Depending on the profile selected in <multiOsCluster directory>/config/apps.json

 /appControl/<application name>/ 





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
