
#this is just a collection of snippet. once configured, paraview launching is much easier than openspace launching.

#cd D:\apps\ParaView\v5.8.0_git_official_CAVE\bin\

#smpd -d

#mpiexec.exe -np 2 -machinefile ".\machines.txt"  D:\apps\ParaView\v5.8.0_git_official_CAVE\bin\pvserver.exe D:\apps\ParaView\v5.8.0_git_official_CAVE\bin\dome_arena.pvx

#.\paraview.exe --server=domeServer_rt1