#cd 'C:\Program Files\Microsoft MPI\Bin'

#.\mpiexec.exe -np 2 -machinefile D:\apps\ParaView\v5.8.0_git_official_CAVE\bin\machines.txt  D:\apps\ParaView\v5.8.0_git_official_CAVE\bin\pvserver.exe D:\apps\ParaView\v5.8.0_git_official_CAVE\bin\dome_arena.pvx

mpiexec.exe -np 2 -machinefile D:\apps\ParaView\v5.8.0_git_official_CAVE\bin\machines.txt  D:\apps\ParaView\v5.8.0_git_official_CAVE\bin\pvserver.exe D:\apps\ParaView\v5.8.0_git_official_CAVE\bin\dome_arena.pvx