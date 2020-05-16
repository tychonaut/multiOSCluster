

# Workflow for compiling, deploying, configuring and running ParaView on each dome computer, for Windows OS:
--------------------------------------------------------------------------------------------------------------

This document describes the process of setting up machines, then building, deploying, configuring and launching ParaView in a dome-cluster

There are many different tutorial pages concering the build. None of them has worked in all respects for me.
Yet one came pretty close, and this guide follows it: [ParaView/VRPN with MS-MPI](https://www.paraview.org/Wiki/ParaView/VRPN_with_MS-MPI)



## Get and compile ParaView cluster-ready:
------------------------------------------

Follow [ParaView/VRPN with MS-MPI](https://www.paraview.org/Wiki/ParaView/VRPN_with_MS-MPI), 
but mind the following corrections and supplements :

* use newest Microsoft MPI (MS-MPI v10.1.2 at time of writing), not the old 2008 version

* You can use the newest Qt (5.14 at time of writing), in constrast to many sites mentioning 5.9.

* In ParaView v5.8.0, there is a hardcoded requirement for Qt in `VTK/GUISupport/Qt/CMakeLists.txt`:
	> VERSION    5.9
	Before compiling, change this to newest version (5.14 in my case) in the CMakeLists.txt 
	(hacky, but haven't found time to explore non-hardcoded alternatives)
	> VERSION    5.14


* The full name for " MSVC 2017 (x64) command prompt" is on my machine was:
  "x64 Native Tools Command Prompt for VS 2017"

* The build only succeeds on Release build: 
  CMAKE_BUILD_TYPE=Release
  

* Set installation to sth else, so you don't need admin and can maintain different build versions:
	CMAKE_INSTALL_PREFIX=D:\apps\ParaView\v5.8.0_CAVE

* Maybe check documentation install
	INSTALL_DOCS=true
	(doesnt seem to have any effect)

* Some flag names have changed. But you can guess the mapping:
	* PARAVIEW_ENABLE_PYTHON 			-> PARAVIEW_USE_PYTHON
	* PARAVIEW_BUILD_QT_GUI  			-> PARAVIEW_USE_QT
	* PARAVIEW_BUILD_PLUGIN_VRPlugin	-> PARAVIEW_PLUGIN_ENABLE_VRPlugin
	* VTK_Python_VERSION 				-> (missing, hopefully for good)
	* VTK_Python_VERSION -> PARAVIEW_PYTHON_VERSION 

* Don't care about python 2.7; Python 3.8 also works:
	PARAVIEW_PYTHON_VERSION = 3

* All flags containing MPI seem to have significantly changed in name and structure.
  Cmake seems to have found what it needs from MPI by itself, to the following flags don't need bothering:
	MPI_C_INCLUDE_PATH
	MPI_CXX_INCLUDE_PATH
	MPIEXEC
	VTK_MPIRUN_EXE
	MPI_C_LIBRARIES
	MPI_CXX_LIBRARIES
	MPI_LIBRARY
	
* 	PARAVIEW_USE_VRPN  -> PARAVIEW_PLUGIN_VRPlugin_USE_VRPN
	
* VTK_MPI_NUMPROCS=2 looks fishy. Leave it alone tohugh, seems tetsing stuff, 
	not total process count for mpi apps
  https://gitlab.kitware.com/lugia-kun/vtk/commit/023f07ea1524f8ca1da2e3a6f1fe147f9b58a752

* VRPN_INCLUDE_DIR: Do as stated in the tutorial, although it sounds fishy; Will Fail otherwise
* VRPN_LIBRARY:  Enter  only `<path to build dir>/vrpn.lib`, 
	NOT also the quat.lib, especially not a quatd.lib, as stated in the tutorial!





## Execute compiled ParaView:
-------------------------------

For a quick sanity check, simply run either in powershell or by double clicking:
`<paraview build dir>/bin/paraview.exe`


## Install ParaView on building machine
-------------------------------------------

ninja install

## Deploy ParaView installation to cluster
--------------------------------------------

* Configure the `<multiOSCluster dir>/config/apps.json` so they contain all master and slves nodes
  that are supposed to be part of the cluster.

* Configure the "ParaView" entries for Windows in `<multiOSCluster dir>/config/apps.json`:
  Set at least the "InstallDir"-entry (same value that was given to CMAKE_INSTALL_PREFIX variable above).

* Copy contents of the local install dir to the same directory on all cluster machines:
  Run in Msys2 bash:  
  `<multiOSCluster dir>/appControl/rsyncAppInstallDirToCluster.sh ParaView`
  
* Install all dependencies on each cluster node, see 
  [ParaView/VRPN with MS-MPI]( https://www.paraview.org/Wiki/ParaView/VRPN_with_MS-MPI ), 
  Section "To run the exe on slave computers for rendering".
  
  TODO do and describe smpd -d stuff

* Specify an active configuration profile for Paraview:
  in `<multiOSCluster dir>/appControl/<app name>/profiles` you find, can change and create folders,
  where each toplevel folder represents a profile for `<app name>`.
  Each "profile folder" contains files used by ParaView in order to run in a certain way.
  As an example, we take the ARENA2 visualizationation dome:
  You want to  configure ParaView to run as a visualization cluster in the dome
  (warping and blending is accounted for externally, e.g. via 
  [VIOSO AnyBlend VR & Sim](https://vioso.com/software/vioso-anyblend-vrsim/); 
  But view frusta, window position, resolution etc. still need to be specified to ParaView).
  
  To better understand the config files involved, the general workflow to launch such a config is:
	1. Launch controlling paraview instance on master (paraview client in ParaView terminology),
	   tell it the name of the server configuration to connect to, e.g.:
	   `<paraview build dir>/bin/paraview.exe --server=arenaCluster`
	   This is all it is to launching from the user's perspective. Under the hood,
	   the following happens:
	2. 
	 
	   
  
  There are four critical aspects for launching such a configuration:
	1. Specify a server configuration file (default_servers.pvsc):
	   Follow [this tutorial](https://www.paraview.org/Wiki/ParaView:Server_Configuration)
	   t
	   
		Notes: surround everything with 
		<?xml version="1.0" ?>
		<Servers>
		...
		</Servers>

  
  
* Copy config files for selected profile to the local install directory on all cluster machines:
  Run in Msys2 bash:  
  `<multiOSCluster dir>/appControl/rsyncAppConfigToCluster.sh ParaView`







There is one important piece of information missing in the main tutorial, and trying to get it from different sources can be misleading:

> Use `mpiexec <relevant args> pvserver.exe <relevant-pvx>.pvx` to main computer to run pvserver

 `<relevant args> := 
	-np <number of cluster instances> -machinefile <textfile containing all cluster slave host names>`


## Launch ParaView cluster
--------------------------------------------

 Pretty simple, compared to other apps and compared to the previous setup: run in powershell:
 `<paraview build dir>/bin/paraview.exe --server=<server name specified default_servers.pvsc>`
 Example:
 `D:\apps\ParaView\v5.8.0_CAVE\bin\paraview.exe --server=arenaCluster`


## TODOS:
---------

- build Paraview with docs
- find out how to load & debug ninja builds with visual studio (or qt creator)
- find out how to debug Microsoft MPI network stuff
- find reason for and fix issue of pvserver crash upon mouse click or opened task manager
